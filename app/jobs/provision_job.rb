require 'rubyipmi'

class ProvisionJob < ApplicationJob
  queue_as :default

  def perform(provision, ilo_scan_job)

    #Insert delay for view status update
    sleep 2

    #Define thread pool
    pool = Concurrent::FixedThreadPool.new(100)

    #Power off method
    def power_down(conn)
      #Try a graceful shutdown first
      conn.chassis.power.softShutdown
      #If graceful shutdown fails, force reboot in 60 seconds
      begin
        Timeout::timeout(180) {
          sleep(10) until conn.chassis.power.off?
        }
      rescue Timeout::Error
        conn.chassis.power.off
        sleep 5
      end
      #Set false if server does not shut off
      return conn.chassis.power.off?
    end

    #Power on pxe method
    def power_on_pxe(conn)
      #Set server to boot in PXE mode
      begin
        Timeout::timeout(80) {
          conn.chassis.bootpxe(reboot=true, persistent=true)
        }
      rescue Timeout::Error
        logger.warn("Timeout Reached - PXE Boot Fail!")
      end
      for i in 0..1
        if conn.chassis.power.on?
          return true
        end
        conn.chassis.power.on
        sleep 5
      end
      #Set false if server does not power on
      return conn.chassis.power.on?
    end

    #Define how to call the Foreman API
    authenticator = ApipieBindings::Authenticators::BasicAuth.new( 'admin', ENV["FOREMAN_PASSWORD"] )
    api = ApipieBindings::API.new( { :uri => 'https://foreman.am2.hpelabs.net/', :authenticator => authenticator, :api_version => '2' } )

    def server_discovered(authenticator, api, status_record, ilo_scan_job)
      serial_record = status_record.pluck(:server_serial)
      serial = serial_record.join
      provision_state = api.resource(:fact_values).call( :index, :search => "#{serial}" )
      begin
        Timeout::timeout(600) {
          while provision_state['results'].empty? do
            sleep 15
            provision_state = api.resource(:fact_values).call( :index, :search => "#{serial}" )
          end
        }
      rescue Timeout::Error
        logger.warn("Timeout Reached - Server not found in Foreman!")
      end
      return !provision_state['results'].empty?
    end
    
    #Take each bmc address and boot the server into PXE mode
    catch :break_out do
      provision.each do |address|
        Concurrent::Promise.execute(executor: pool) do
          conn = Rubyipmi.connect(ilo_scan_job.ilo_username, ilo_scan_job.ilo_password, address, "freeipmi", {:driver => "lan20"} )
          status_record = ScanResult.where("ilo_address = ? AND ilo_scan_job_id = ?", address, ilo_scan_job.id)
          ActiveRecord::Base.connection_pool.with_connection do
            status_record.update(provision_status: 'Executing Graceful Shutdown')
          end
          ActiveRecord::Base.connection_pool.with_connection do
            if !power_down(conn)
              status_record.update(provision_status: 'Error: Unable to Power Down Server')
              throw :break_out
            else
              status_record.update(power_status: 'Off', provision_status: 'Server Powered Off')
            end
          end
          ActiveRecord::Base.connection_pool.with_connection do
            if !power_on_pxe(conn)
              status_record.update(provision_status: 'Error: Unable to Power On Server')
              throw :break_out
            else
              status_record.update(power_status: 'On', provision_status: 'Powered On.  Discovering Server')
            end
          end
          ActiveRecord::Base.connection_pool.with_connection do
            if !server_discovered(authenticator, api, status_record, ilo_scan_job)
              status_record.update(provision_status: 'Error: Unable to Discover Server')
              ilo_scan_job.update(status: 'Error During Provisioning')
              throw :break_out
            else
              status_record.update(provision_status: 'Server Discovered into Backend')
            end
          end
        end
      end
    end

    #Wait for threads to finish
    pool.shutdown
    pool.wait_for_termination(timeout = 900)

    sleep 2

    if ilo_scan_job.status != "Error During Provisioning"
      ilo_scan_job.update(status: 'Servers Provisioned')
    end

  end
end
