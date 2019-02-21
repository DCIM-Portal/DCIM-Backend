module BmcDrivers
  module Ipmi
    extend ActiveSupport::Concern

    def fru_list
      tries_remaining ||= 3
      result = freeipmi_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).fru.list, read_timeout: 180)
      # Check for known FRU list edge cases
      system_fru0 = deep_find('system_fru0', result)
      # FreeIPMI cannot FRU list HPE ProLiant Gen6 servers
      if system_fru0.is_a?(Hash) && system_fru0.value?('common header checksum invalid')
        result = ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).fru.list, read_timeout: 180)
      end
      result
    rescue Dcim::SdrCacheError
      retry if ((tries_remaining -= 1) > 0) && http_smart_proxy_bmc_request(smart_proxy.onboard.bmc.sdr_cache, method: :delete)
      raise
    end

    def shutdown
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.power.soft, method: :put)
    end

    def power_off
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.power.off, method: :put)
    end

    def power_on_pxe(persistent: true)
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.config.bootdevice.pxe,
                                       payload: { reboot: true, persistent: persistent },
                                       method: :put)
    end

    def power_on_bios
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.config.bootdevice.bios, payload: { reboot: true }, method: :put)
    end

    def power_on
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.power.on, method: :put)
    end

    def power_on?
      status = ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).chassis.power.status)
      update(power_status: status)
      power_status_on?
    rescue ArgumentError => e
      raise Dcim::UnsupportedApiResponseError, e.to_s, e.backtrace
    end

    def test
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).test)
    end

    def reset_bmc(type = 'cold')
      type = 'cold' if type != 'warm'
      ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(ip_address).bmc.reset, payload: { type: type }, method: :put)
    end

    private

    def freeipmi_smart_proxy_bmc_request(query, payload: {}, method: :get, **kwargs)
      http_smart_proxy_bmc_request(query, payload: { 'bmc_provider' => 'freeipmi' }.merge(payload), method: method, **kwargs)
    rescue Dcim::UnknownError
      http_smart_proxy_bmc_request(query, payload: { 'bmc_provider' => 'ipmitool' }.merge(payload), method: method, **kwargs)
    end

    def ipmitool_smart_proxy_bmc_request(query, payload: {}, method: :get, **kwargs)
      http_smart_proxy_bmc_request(query, payload: { 'bmc_provider' => 'ipmitool' }.merge(payload), method: method, **kwargs)
    rescue Dcim::UnknownError
      http_smart_proxy_bmc_request(query, payload: { 'bmc_provider' => 'freeipmi' }.merge(payload), method: method, **kwargs)
    end

    def http_smart_proxy_bmc_request(query, payload: nil, method: :get, **kwargs)
      begin
        full_result = query.send(method, user: username, password: password, payload: payload, **kwargs).to_hash
        action = full_result['action']
        result = full_result['result']
        return result if action == 'test'
      rescue RestClient::Unauthorized
        raise Dcim::InvalidCredentialsError
      end
      # Handle freeipmi errors
      if result.is_a? Hash
        # freeipmi: {"/path/to/binary":"string"}
        raise Dcim::InvalidCredentialsError if result.value? 'invalid'
        raise Dcim::ConnectionTimeoutError if result.value? 'timeout'

        # freeipmi: {"":{"/path/to/binary":"string"}}
        freeipmi_error = result[''] if result.keys.length == 1
        unless freeipmi_error.nil?
          raise Dcim::SmartProxyError, freeipmi_error if freeipmi_error.is_a?(Hash) && freeipmi_error.any? { |key, value| key =~ /cannot_.*_cache_directory/ }
          raise Dcim::InvalidUsernameError if freeipmi_error.value? 'username invalid'
          raise Dcim::InvalidPasswordError if freeipmi_error.value? 'password invalid'
          raise Dcim::ConnectionTimeoutError if freeipmi_error.value? 'connection timeout'
          raise Dcim::SessionTimeoutError if freeipmi_error.value? 'session timeout'
          raise Dcim::BmcBusyError if freeipmi_error.value? 'BMC busy'
          raise Dcim::SdrCacheError if freeipmi_error.value? 'Please flush the cache and regenerate it'
          raise Dcim::UnsupportedApiResponseError if freeipmi_error.value? 'missing argument'

          # ¯\_(ツ)_/¯
          raise Dcim::UnknownError, result
        end
      end
      # freeipmi: "string"
      if result.is_a? String
        raise Dcim::InvalidUsernameError if result == 'username invalid'
        raise Dcim::InvalidPasswordError if result == 'password invalid'
        raise Dcim::ConnectionTimeoutError if result == 'connection timeout'
        raise Dcim::SessionTimeoutError if result == 'session timeout'
        raise Dcim::BmcBusyError if result == 'BMC busy'
        raise Dcim::SdrCacheError if result == 'Please flush the cache and regenerate it'
        raise Dcim::UnsupportedApiResponseError if result.include? 'missing argument'
      end
      # All other failures, including ipmitool, which provides no error messages
      raise Dcim::UnknownError unless result

      result
    end

    def deep_find(key, object = self, found = nil)
      if object.respond_to?(:key?) && object.key?(key)
        object[key]
      elsif object.is_a? Enumerable
        object.find { |*a| found = deep_find(key, a.last) }
        found
      end
    end
  end
end
