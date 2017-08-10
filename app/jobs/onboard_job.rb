class OnboardJob < ApplicationJob
  queue_as :default

  def perform(**kwargs)
    store_dependencies(**kwargs)

    prepare_to_run

    if serial_onboarded?
      @logger.debug "BmcHost #{@request.bmc_host.id} already discovered. Skipping to associate System to BmcHost..."
    else
      # Step 1: Shut down gracefully
      start_step(:shutdown)
      begin
        keep_trying(every: 5, timeout: 180, until: false) do
          shutdown
          power_on?
        end
      rescue Timeout::Error
      end
  
      # Step 2: Power off
      start_step(:power_off)
      begin
        keep_trying(every: 5, timeout: 20, until: false) do
          power_off
          power_on?
        end
      rescue Timeout::Error
        raise Dcim::JobTimeoutError
      end
  
      # Step 3: Reboot into PXE
      start_step(:pxe)
      begin
        keep_trying(every: 5, timeout: 80, until: true) do
          power_on_pxe
          power_on?
        end
      rescue Timeout::Error
        raise Dcim::JobTimeoutError
      end
  
      # Step 4: Discover Foreman host
      start_step(:discover)
      begin
        keep_trying(every: 15, timeout: 600, until: true) do
          serial_onboarded?
        end
      rescue Timeout::Error
        raise Dcim::JobTimeoutError
      end
    end

    # Step 5: Promote Host::Discovered to Host::Managed
    start_step(:manage)
    foreman_host_id = nil
    begin
      keep_trying(every: 15, timeout: 60, until: true) do
        system_name = serial_to_system_name
        foreman_host_id = system_name_to_system_id(system_name)
        foreman_host_id.is_a? Integer
      end
    rescue Timeout::Error
      raise Dcim::JobTimeoutError
    end
    system = System.find_by(foreman_host_id: foreman_host_id)
    system ||= System.new(foreman_host_id: foreman_host_id)
    @request.bmc_host.system = system
    system.save!
    @request.bmc_host.save!

    # Step 6: Add BmcHost credentials to Foreman NIC
    start_step(:bmc_creds)
    result = @foreman_resource.api.hosts(foreman_host_id).interfaces.get.to_hash["results"]
    interface = result.detect { |h| h["type"] == "bmc" }
    interface_id = interface["id"]
    payload = {'username': @request.bmc_host.username,
               'password': @request.bmc_host.password,
               'type':     'bmc'}
    @foreman_resource.api.hosts(foreman_host_id).interfaces(interface_id).put(payload.to_json)

    finish_job
  rescue RuntimeError => e
    fail_with_error(e)
  end

  def store_dependencies(**kwargs)
    begin
      @foreman_resource = kwargs[:foreman_resource]
      @foreman_resource = YAML::load(@foreman_resource) unless @foreman_resource.is_a? Dcim::ForemanApi
    rescue RuntimeError
      # Default to system-wide ForemanApi
      @foreman_resource = Dcim::ForemanApiFactory.instance
    end
    @request = kwargs[:request]
    @logger = kwargs[:logger] || Rails.logger
  end

  def keep_trying(**kwargs, &block)
    result = !kwargs[:until]
    Timeout::timeout(kwargs[:timeout] || 0) do
      until result == kwargs[:until]
        result = block.call
        sleep kwargs[:every] || 5 if result != kwargs[:until]
      end
    end
  end

  def prepare_to_run
    @logger.debug "Preparing to run job #{@request.id}..."
    @request.status = nil
    @request.step = nil
    @request.error_message = nil
    @request.save!
  end

  def start_step(symbol)
    @logger.debug "Starting step #{symbol}..."
    @request.step = symbol
    @request.status = :in_progress
    @request.save!
  end

  def fail_with_error(e)
    if e.is_a? Dcim::JobTimeoutError
      @request.status = :timeout
      @logger.debug "Job timed out on step #{@request.step} and failed"
    else
      @request.status = :stack_trace
      @request.error_message = e.class.name + ": " + e.message + "\n" + e.backtrace.join("\n")
      @logger.debug "Job failed with stack trace:"
      @logger.debug @request.error_message
    end
    @request.save!
  end

  def finish_job
    @logger.debug "Job #{@request.id} finished successfully!"
    @request.status = :success
    @request.step = :complete
    @request.save!
  end

  def shutdown
    @request.bmc_host.shutdown
  end

  def power_on_pxe
    @request.bmc_host.power_on_pxe
  end

  def power_off
    @request.bmc_host.power_off
  end

  def power_on?
    @request.bmc_host.power_on?
  end

  def look_up_serial
    results = @foreman_resource.api.fact_values.get(payload: {search: "facts.serialnumber=" + @request.bmc_host.serial}).to_hash["results"]
    raise Dcim::UnsupportedApiResponseError if results.nil? || !results.is_a?(Hash)
    raise Dcim::DuplicateSerialError if results.size > 1
    results
  end

  def serial_onboarded?
    look_up_serial.size == 1
  end

  def serial_to_system_name
    result = look_up_serial.keys[0]
    return false if !result or result.empty?
    result
  end

  def system_name_to_system_id(system_name)
    return false if !system_name or system_name.empty?
    result = @foreman_resource.api.hosts(system_name).get.as_json["id"]
    return result.to_i if result
    result
  end
end
