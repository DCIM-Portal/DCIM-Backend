require 'rubyipmi'

# XXX: Assign proper name for this class and move it into its own class file
class ProgressCable
  def initialize(steps, **kwargs)
    @steps = steps
    @id = kwargs[:id]
    @step = 0
    @task = nil
    @range_total = @steps.inject(0) {|sum, hash| sum + hash[:range]}
    @range_used = 0.0
  end

  def shutdown()
    @task.try(:kill)
    emit_progress_percentage
    return true
  end

  def advance()
    @task.try(:kill)
    if @step >= @steps.length
      @last_progress_percentage = 100
      emit_progress_percentage
      return false
    end
    @step += 1
    if @step > 1
      @range_used += @steps[@step-2][:range].to_f
    end
    @time_start = Time.now.to_i
    launch_timer
    return true
  end

  def current_step
    return @steps[@step-1]
  end
  
  def launch_timer
    @task = Concurrent::TimerTask.new(execution_interval: 1, timeout_interval: current_step[:timeout], run_now: true) do
      time_elapsed = Time.now.to_i - @time_start
      progress_current = (@range_used + (current_step[:range] * time_elapsed / current_step[:timeout])) / @range_total
      # Round down calculated progress percentage
      progress_current_percentage = (100 * progress_current).to_i
      if progress_current_percentage != @last_progress_percentage
        @last_progress_percentage = progress_current_percentage
        emit_progress_percentage
      end
    end
    @task.execute
  end

  def emit_progress_percentage
    # TODO: Use actual channel for progress updates
    ActionCable.server.broadcast 'status_channel', { percent: @last_progress_percentage.to_s, status_address: @id }
  end
end

class ProvisionJob < ApplicationJob
  queue_as :default

  def initialize(*args)
    super
    @api_adminurl = ENV["FOREMAN_URL"]
    @api_username = ENV["FOREMAN_USERNAME"] || 'admin'
    @api_password = ENV["FOREMAN_PASSWORD"]
  end

  def perform(provision, ilo_scan_job)
    # Recipe for provisioning
    steps = [{:method => "power_off_graceful", :name => "Power Off Gracefully", :range => 30, :timeout => 180, :if_success_skip_steps => 1, :ignore_timeout => true},
             {:method => "power_off_now",      :name => "Power Off Forcefully", :range => 3,  :timeout => 20},
             {:method => "power_on_pxe",       :name => "Power On and PXE Boot", :range => 17, :timeout => 80},
             {:method => "server_discovered?", :name => "Discover", :range => 50, :timeout => 600}]
 
    #Insert delay for view status update
    sleep 2

    #Define thread pool
    pool = Concurrent::FixedThreadPool.new(100)
   
    #Take each bmc address and boot the server into PXE mode
    provision.each do |address|
      Concurrent::Promise.execute(executor: pool) do
        conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "ipmitool", {:driver => "lan20"} )
        status_record = ScanResult.where("ilo_address = ? AND ilo_scan_job_id = ?", address, ilo_scan_job.id)
        update_job_record(ilo_scan_job, status: "Provisioning Servers")
        pbar = ProgressCable.new(steps, id: address)
        catch :break_out {
          while pbar.advance
            begin
              Timeout::timeout(pbar.current_step[:timeout]) {
                update_status_record(status_record, conn, "Attempting to " + pbar.current_step[:name])
                if !send(pbar.current_step[:method], conn: conn, record: status_record, job: ilo_scan_job)
                  update_status_record(status_record, conn, "Error: Failed to " + pbar.current_step[:name])
                  update_job_record(ilo_scan_job, status: "Error During Provisioning")
                  throw :break_out
                end
                update_status_record(status_record, conn, "Task Completed: " + pbar.current_step[:name])
                for i in 0..(pbar.current_step[:if_success_skip_steps].to_i-1)
                  pbar.advance
                end
              }
            rescue Timeout::Error
              update_status_record(status_record, conn, "Error - Timed Out: " + pbar.current_step[:name])
              unless pbar.current_step[:ignore_timeout]
                throw :break_out
              end
            end
          end
        }
        pbar.shutdown
      end
    end

    #Wait for threads to finish
    pool.shutdown
    # XXX: Maybe calculate timeout based on total timeout of recipe/steps
    pool.wait_for_termination(timeout = 900)

    sleep 2

    if !ilo_scan_job.status.include? "Error"
      ilo_scan_job.update(status: 'Servers Provisioned')
    end
  end

  # Method: get power status as string
  def power_status_s(conn:, **)
    if conn.chassis.power.on?
      return "On"
    end
    return "Off"
  end

  # Method: power off graceful
  def power_off_graceful(conn:, **)
    conn.chassis.power.softShutdown
    sleep(5) until conn.chassis.power.off?
    return conn.chassis.power.off?
  end

  # Method: power off forceful
  def power_off_now(conn:, **)
    conn.chassis.power.off
    sleep(1) until conn.chassis.power.off?
    return conn.chassis.power.off?
  end

  # Method: power on pxe
  def power_on_pxe(conn:, **)
    conn.chassis.bootpxe(reboot=true, persistent=true)
    for i in 0..1
      if conn.chassis.power.on?
        return true
      end
    end
    begin
      conn.chassis.power.on
      sleep(5)
    end until conn.chassis.power.on?
    return conn.chassis.power.on?
  end

  # Method: Is the server a discovered_host in Foreman?
  def server_discovered?(conn:, record:, job:, **)
    authenticator = ApipieBindings::Authenticators::BasicAuth.new( @api_username, @api_password )
    api = ApipieBindings::API.new( { :uri => @api_adminurl, :authenticator => authenticator, :api_version => '2' } )

    serial = record.pluck(:server_serial).join
    provision_state = nil
    begin
      provision_state = api.resource(:fact_values).call( :index, :search => "#{serial}" )
      while provision_state['results'].empty? do
        provision_state = api.resource(:fact_values).call( :index, :search => "#{serial}" )
        if !provision_state['results'].empty?
          return true
        end
        sleep 15
      end
    rescue
      logger.warn "Apipie request failed"
      return false
    end
    return !provision_state['results'].empty?
  end

  # Method: Update status record with provision status
  def update_status_record(record, conn, provision_status)
    ActiveRecord::Base.connection_pool.with_connection do
      record.update(power_status: power_status_s(conn: conn), provision_status: provision_status)
    end
  end

  # Method: Update scan job record
  def update_job_record(record, **kwargs)
    ActiveRecord::Base.connection_pool.with_connection do
      record.update(kwargs)
    end
  end
end
