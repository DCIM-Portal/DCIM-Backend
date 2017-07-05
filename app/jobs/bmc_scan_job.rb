class BmcScanJob < ApplicationJob
  queue_as :default

  def initialize(**kwargs)
    @foreman_resource = kwargs[:foreman_resource]
    @request = kwargs[:request]
    @logger = kwargs[:logger] || Rails.logger
  end


  def perform
    @request.error_message = nil
    @request.update(status: :in_progress)

    smart_proxy = get_onboard_smart_proxy
    unless smart_proxy
      @request.update(status: :smart_proxy_unreachable)
      return false
    end
    @logger.info "Suitable Smart Proxy found: " + smart_proxy.instance_variable_get(:@resource).instance_variable_get(:@url)

    begin
      bmc_hosts = list_bmc_hosts(smart_proxy)
    rescue Dcim::BmcScanError => e
      @request.error_message = e.message
      @request.update(status: :invalid_range)
      return false
    end
    @logger.info "BMC hosts found: " + bmc_hosts.to_s

    pool = Concurrent::FixedThreadPool.new(100)

    promises = {}
    bmc_hosts.each do |bmc_host_ip|
      bmc_host = BmcHost.find_by(ip_address: bmc_host_ip)
      bmc_host = BmcHost.new(ip_address: bmc_host_ip,
                             zone: @request.zone) if !bmc_host
      bmc_host.error_message = nil
      bmc_host.save
      promises[bmc_host_ip] = Concurrent::Promise.execute(executor: pool) do
        @logger.debug bmc_host_ip + ": Created new BMC host"
        bmc_host_info_hash = get_bmc_host_info(bmc_host_ip, @request.brute_list, smart_proxy)
        @logger.debug bmc_host_ip + ": Got BMC host info: " + bmc_host_info_hash.to_s
        bmc_host_info_hash.each { |name, value| bmc_host.send(name.to_s + "=", value) }
        bmc_host.zone = @request.zone
        bmc_host.scan_status = :success
        ActiveRecord::Base.connection_pool.with_connection do
          bmc_host.save
        end
      end
    end

    pool.shutdown
    pool.wait_for_termination(timeout = 180)

    promises.each do |bmc_host_ip, promise|
      if promise.rejected?
        error = promise.reason
        @logger.warn bmc_host_ip + ": Promise rejected with reason: " + error.to_s
        bmc_host = BmcHost.find_by(ip_address: bmc_host_ip)
        begin
          bmc_host.scan_status = error.class.name.demodulize.underscore
        rescue ArgumentError
          bmc_host.scan_status = :stack_trace
          bmc_host.error_message = error.class.name + ": " + error.message + "\n" + error.backtrace.join("\n")
        end
        bmc_host.save
      end
    end

    @request.update(status: :scan_complete)
    true
  end

  private

  def get_onboard_smart_proxy
    location = @foreman_resource.api.locations(@request.zone_id).get
    location["smart_proxies"].each do |smart_proxy|
      begin
        smart_proxy_resource = Dcim::SmartProxyApi.new(url: smart_proxy["url"])
      rescue RuntimeError
        next
      end
      return smart_proxy_resource if smart_proxy_resource.features.get.to_hash.include? "onboard"
    end
    false
  end

  def list_bmc_hosts(smart_proxy_resource)
    response = smart_proxy_resource.onboard.bmc.scan.range(@request.start_address, @request.end_address).get(timeout: 600).to_hash
    raise Dcim::BmcScanError, response["error"] if response.key?("error")
    response["result"]
  end

  def get_bmc_host_info(ip, brute_list, smart_proxy_resource)
    e = nil
    no_credentials_worked = nil
    brute_list.brute_list_secrets.each do |secret|
      begin
        @logger.debug ip + ": Getting BMC host info: Trying secret with username \"" + secret[:username] + "\" and password \"" + secret[:password] + "\""
        no_credentials_worked = false
        fru_list = freeipmi_smart_proxy_bmc_request(smart_proxy_resource.bmc(ip).fru.list, secret)
        model, serial = get_model_and_serial_from_fru_list(fru_list)
        power_status = ipmitool_smart_proxy_bmc_request(smart_proxy_resource.bmc(ip).chassis.power.status, secret)
        collected_info = {system_model: model, serial: serial, power_status: power_status, username: secret[:username], password: secret[:password]}
        return collected_info
      rescue Dcim::InvalidCredentialsError => e
        no_credentials_worked = true
        next
      rescue Dcim::UnknownError
      end
    end
    raise e if no_credentials_worked
    raise Dcim::UnknownError, "Unknown error after exhausting brute_list"
  end

  def freeipmi_smart_proxy_bmc_request(query, secret)
    http_smart_proxy_bmc_request(query, secret, "bmc_provider=freeipmi")
  rescue Dcim::UnknownError
    http_smart_proxy_bmc_request(query, secret, "bmc_provider=ipmitool")
  end

  def ipmitool_smart_proxy_bmc_request(query, secret)
    http_smart_proxy_bmc_request(query, secret, "bmc_provider=ipmitool")
  rescue Dcim::UnknownError
    http_smart_proxy_bmc_request(query, secret, "bmc_provider=freeipmi")
  end

  def http_smart_proxy_bmc_request(query, secret, payload=nil)
    result = query.get(user: secret[:username], password: secret[:password], payload: payload).to_hash["result"]
    # Handle freeipmi errors
    if result.is_a? Hash
      # freeipmi: {"/path/to/binary":"string"}
      raise Dcim::InvalidCredentialsError if result.value? "invalid"
      raise Dcim::ConnectionTimeoutError if result.value? "timeout"
      # freeipmi: {"":{"/path/to/binary":"string"}}
      freeipmi_error = result[""]
      unless freeipmi_error.nil?
        raise Dcim::InvalidUsernameError if freeipmi_error.value? "username invalid"
        raise Dcim::InvalidPasswordError if freeipmi_error.value? "password invalid"
        raise Dcim::ConnectionTimeoutError if freeipmi_error.value? "connection timeout"
        # ¯\_(ツ)_/¯ 
        raise Dcim::UnknownError
      end
    end
    # freeipmi: "string"
    raise Dcim::InvalidUsernameError if result == "username invalid"
    raise Dcim::InvalidPasswordError if result == "password invalid"
    raise Dcim::ConnectionTimeoutError if result == "connection timeout"
    # All other failures, including ipmitool, which provides no error messages
    if !result || result.empty?
      raise Dcim::UnknownError
    end
    result
  end

  def get_model_and_serial_from_fru_list(fru_list)
    #IBM or HP Server
    if !fru_list["default_fru_device"].nil?
      model = fru_list["default_fru_device"].values_at('board_manufacturer', 'product_name').join(' ')
      serial = fru_list["default_fru_device"]["product_serial_number"]
    #Dell Server
    elsif !fru_list["system_board"].nil?
      model = fru_list["system_board"].values_at('board_manufacturer', 'board_product_name').join(' ')
      serial = fru_list["system_board"]["product_serial_number"]
    #Cisco Server
    elsif !fru_list["fru_ram"].nil?
      model = fru_list["fru_ram"].values_at('board_manufacturer', 'product_name').join(' ')
      serial = fru_list["fru_ram"]["product_serial_number"]
    #Supermicro
    elsif !fru_list["bmc_fru"].nil?
      model = fru_list["bmc_fru"].values_at('board_manufacturer', 'product_part/model_number').join(' ')
      serial = fru_list["bmc_fru"]["product_serial_number"]
    #Unable to access BMC or unsupported model
    else
      raise Dcim::UnsupportedFruError
    end
    return model, serial
  end

end
