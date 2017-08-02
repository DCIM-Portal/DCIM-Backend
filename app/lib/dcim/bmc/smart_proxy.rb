module Dcim::Bmc
  class SmartProxy < Base
    # BmcScanJob methods
    def fru_list
      @fru_list ||= freeipmi_smart_proxy_bmc_request(@resource.bmc(@ip).fru.list)
    end

    def model(fru_list=nil)
      model, serial = get_model_and_serial_from_fru_list(self.fru_list)
      model
    end

    def serial(fru_list=nil)
      model, serial = get_model_and_serial_from_fru_list(self.fru_list)
      serial
    end

    # OnboardJob methods
    def power_on?
      ipmitool_smart_proxy_bmc_request(@resource.bmc(@ip).chassis.power.status)
    end

    def shutdown
      ipmitool_smart_proxy_bmc_request(@resource.bmc(@ip).chassis.power.on, method: :put)
    end
    
    def power_off
      raise NotImplementedError
    end

    def power_on_pxe
      raise NotImplementedError
    end

    private

    def freeipmi_smart_proxy_bmc_request(query)
      http_smart_proxy_bmc_request(query, "bmc_provider=freeipmi")
    rescue Dcim::UnknownError
      http_smart_proxy_bmc_request(query, "bmc_provider=ipmitool")
    end
  
    def ipmitool_smart_proxy_bmc_request(query)
      http_smart_proxy_bmc_request(query, "bmc_provider=ipmitool")
    rescue Dcim::UnknownError
      http_smart_proxy_bmc_request(query, "bmc_provider=freeipmi")
    end

    def http_smart_proxy_bmc_request(query, payload=nil, method: :get)
      begin
        result = query.send(method, user: self.username, password: self.password, payload: payload).to_hash["result"]
      rescue RestClient::Unauthorized
        raise Dcim::InvalidCredentialsError
      end
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
          raise Dcim::SessionTimeoutError if freeipmi_error.value? "session timeout"
          raise Dcim::BmcBusyError if freeipmi_error.value? "BMC busy"
          raise Dcim::SdrCacheError if freeipmi_error.value? "Please flush the cache and regenerate it"
          raise Dcim::UnsupportedApiResponseError if freeipmi_error.value? "missing argument"
          # ¯\_(ツ)_/¯ 
          raise Dcim::UnknownError
        end
      end
      # freeipmi: "string"
      raise Dcim::InvalidUsernameError if result == "username invalid"
      raise Dcim::InvalidPasswordError if result == "password invalid"
      raise Dcim::ConnectionTimeoutError if result == "connection timeout"
      raise Dcim::SessionTimeoutError if result == "session timeout"
      raise Dcim::BmcBusyError if result == "BMC busy"
      raise Dcim::SdrCacheError if result == "Please flush the cache and regenerate it"
      raise Dcim::UnsupportedApiResponseError if result.include? "missing argument"
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
end
