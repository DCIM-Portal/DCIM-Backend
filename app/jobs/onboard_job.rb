# XXX: Redo this for new OnboardRequest class
class OnboardJob < ApplicationJob
  queue_as :default

  def perform(**kwargs)
    store_dependencies(**kwargs)
    set_in_progress
    bmc_hosts = set_bmc_hosts_ready_to_onboard

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}
    bmc_hosts.each do |bmc_host|
      promises[bmc_host.id] = Concurrent::Promise.new(executor: pool) do
        onboard(bmc_host)
      end
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      promises.each_value(&:execute)
    end

    pool.shutdown
    pool.wait_for_termination(1200)

    promises.each_value do |promise|
      raise promise.reason, "Error handling failed in an individual onboard (promise): #{promise.reason}", promise.reason.backtrace if promise.rejected?
    end

    finish!
    true
  rescue StandardError => e
    fail_with_error(e)
  end

  def onboard(bmc_host)
    if serial_onboarded?(bmc_host.serial)
      @logger.debug "BmcHost #{bmc_host.id} already discovered. Skipping to associate System to BmcHost..."
    else
      steps = [
        { name: :shutdown,  every: 5,  timeout: 180, until: false, ignore_timeout: true },
        { name: :power_off, every: 5,  timeout: 20,  until: false },
        { name: :pxe,       every: 5,  timeout: 80,  until: true },
        { name: :discover,  every: 15, timeout: 600, until: true }
      ]

      steps.each do |step|
        bmc_host.update(onboard_step: step[:name])
        begin
          keep_trying(every: step[:every], timeout: step[:timeout], until: step[:until]) { send("try_#{step[:name]}", bmc_host) }
        rescue Timeout::Error
          raise Dcim::JobTimeoutError unless step[:ignore_timeout]
        end
      end
    end

    # Step 5: Promote Host::Discovered to Host::Managed
    bmc_host.update(onboard_step: :manage)
    foreman_host_id = nil
    begin
      keep_trying(every: 15, timeout: 60, until: true) do
        system_name = serial_to_system_name(bmc_host.serial)
        foreman_host_id = system_name_to_system_id(system_name)
        foreman_host_id.is_a? Integer
      end
    rescue Timeout::Error
      raise Dcim::JobTimeoutError
    end
    associate_bmc_host_with_system(bmc_host, foreman_host_id)

    # Step 6: Add BmcHost credentials to Foreman NIC
    bmc_host.update(onboard_step: :bmc_creds)
    add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id)

    bmc_host.onboard_step = :complete
    bmc_host.onboard_status = :success
    bmc_host.save!
  rescue Dcim::JobTimeoutError => e
    bmc_host.onboard_status = :timeout
    bmc_host.onboard_error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    bmc_host.save!
  rescue StandardError => e
    bmc_host.onboard_status = :stack_trace
    bmc_host.onboard_error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    bmc_host.save!
  end

  def store_dependencies(**kwargs)
    begin
      @foreman_resource = kwargs[:foreman_resource]
      @foreman_resource = YAML.load(@foreman_resource) unless @foreman_resource.is_a? Dcim::ForemanApi
    rescue TypeError
      # Default to system-wide ForemanApi
      @foreman_resource = Dcim::ForemanApiFactory.instance
    end
    @request = kwargs[:request]
    @logger = kwargs[:logger] || Sidekiq::Logging.logger || Rails.logger
  end

  def keep_trying(**kwargs, &block)
    result = !kwargs[:until]
    Timeout.timeout(kwargs[:timeout] || 0) do
      until result == kwargs[:until]
        result = yield
        sleep kwargs[:every] || 5 if result != kwargs[:until]
      end
    end
  end

  # Step 1: Shut down gracefully
  def try_shutdown(bmc_host)
    bmc_host.shutdown
    bmc_host.power_on?
  end

  # Step 2: Power off
  def try_power_off(bmc_host)
    bmc_host.power_off
    bmc_host.power_on?
  end

  # Step 3: Reboot into PXE
  def try_pxe(bmc_host)
    bmc_host.power_on_pxe
    bmc_host.power_on?
  end

  # Step 4: Discover Foreman host
  def try_discover(bmc_host)
    serial_onboarded?(bmc_host.serial)
  end

  def set_in_progress
    @logger.debug "Preparing to run job #{@request.id}..."
    @request.status = :in_progress
    @request.error_message = nil
    @request.save!
  end

  def fail_with_error(e)
    @request.status = :stack_trace
    @request.error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    @logger.debug 'Job failed with stack trace:'
    @logger.debug @request.error_message
    @request.save!
  end

  def finish!
    @logger.debug "Job #{@request.id} completed!"
    @request.status = :complete
    @request.save!
  end

  def set_bmc_hosts_ready_to_onboard
    validated_bmc_hosts = []
    @request.bmc_hosts.each do |bmc_host|
      begin
        raise Dcim::UnknownError, 'BmcHost#validate_onboardable did not return true' unless bmc_host.validate_onboardable
        bmc_host.onboard_status        = :in_progress
        bmc_host.onboard_step          = nil
        bmc_host.onboard_error_message = nil
        bmc_host.save!
        validated_bmc_hosts << bmc_host
      rescue RuntimeError => error
        bmc_host.onboard_status        = :stack_trace
        bmc_host.onboard_step          = nil
        bmc_host.onboard_error_message = error.class.name + ': ' + error.message + "\n" + error.backtrace.join("\n")
      end
    end
    validated_bmc_hosts
  end

  def look_up_serial(serial)
    results = @foreman_resource.api.fact_values.get(payload: { search: 'facts.serialnumber=' + serial }).to_hash['results']
    raise Dcim::UnsupportedApiResponseError if results.nil? || !results.is_a?(Hash)
    raise Dcim::DuplicateSerialError if results.size > 1
    results
  end

  def serial_onboarded?(serial)
    look_up_serial(serial).size == 1
  end

  def serial_to_system_name(serial)
    result = look_up_serial(serial).keys[0]
    return false if !result || result.empty?
    result
  end

  def system_name_to_system_id(system_name)
    return false if !system_name || system_name.empty?
    result = @foreman_resource.api.hosts(system_name).get.as_json['id']
    return result.to_i if result
    result
  end

  def associate_bmc_host_with_system(bmc_host, foreman_host_id)
    system = ::System.find_by(foreman_host_id: foreman_host_id)
    system ||= ::System.new(foreman_host_id: foreman_host_id)
    bmc_host.system = system
    system.save!
    bmc_host.save!
    system.refresh!
    bmc_host.system == system
  end

  def add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id)
    interfaces = @foreman_resource.api.hosts(foreman_host_id).interfaces.get.to_hash['results']
    raise Dcim::UnsupportedApiResponseError if interfaces.nil? || !interfaces.is_a?(Array)
    interface = interfaces.detect { |h| h['type'] == 'bmc' }
    raise Dcim::MissingRecordError, 'No BMC interface' unless interface
    interface_id = interface['id']
    payload = { 'username' => bmc_host.username,
                'password' => bmc_host.password,
                'type' =>     'bmc' }
    interface = @foreman_resource.api.hosts(foreman_host_id).interfaces(interface_id).put(payload.to_json).to_h
    interface == interface.merge(payload)
  end
end
