require 'resolv'

class BmcHost < ApplicationRecord
  has_many :bmc_scan_request_hosts
  has_many :bmc_scan_requests, -> { distinct }, through: :bmc_scan_request_hosts
  has_one :onboard_request
  enum power_status: {
    off: 0,
    on: 1
  }
  enum sync_status: {
    success: 0,
    in_progress: 1,
    unknown_error: 2,
    stack_trace: 3,
    smart_proxy_error: 4,
    connection_timeout_error: 5,
    invalid_credentials_error: 6,
    invalid_username_error: 7,
    invalid_password_error: 8,
    unsupported_fru_error: 9,
    session_timeout_error: 10,
    bmc_busy_error: 11
  }
  belongs_to :zone
  belongs_to :system, optional: true
  validate :validate_correct_credentials
  validates :ip_address, presence: true, uniqueness: true, format: { with: Resolv::IPv4::Regex }

  def refresh!(secret=nil)
    secret = secret.as_json if secret.is_a? ApplicationRecord
    if secret.is_a? Hash
      logger.debug "Secret passed in; using passed in credentials..."
      self.username = secret['username']
      self.password = secret['password']
    end
    self.sync_status = :in_progress
    self.error_message = nil
    self.save!
    logger.debug "Getting FRU list..."
    frulist = fru_list
    logger.debug "Parsing FRU list..."
    model, serial = get_model_and_serial_from_fru_list(frulist)
    logger.debug "Obtained model \"#{model}\" and serial \"#{serial}\""
    logger.debug "Getting power status..."
    power_status = power_on? ? :on : :off
    logger.debug "Power status is #{power_status}"
    logger.debug "Updating record with obtained information..."
    self.system_model  = model
    self.serial        = serial
    self.power_status  = power_status
    self.sync_status   = :success
    self.save!
    logger.debug "Record updated!"
  rescue RuntimeError => e
    self.error_message = e.class.name + ": " + e.message + "\n" + e.backtrace.join("\n")
    begin
      self.sync_status = e.class.name.demodulize.underscore
      self.save!
    rescue ArgumentError
      self.sync_status = :stack_trace
      self.save!
    end
  end

  def smart_proxy
    unless @smart_proxy_resource.is_a? Dcim::SmartProxyApi
      logger.debug "Looking for suitable Smart Proxy..."
      return @smart_proxy_resource = Dcim::SmartProxyApiFactory.instance(self.zone.foreman_location_id)
    end
    logger.debug "Reusing existing Smart Proxy: " + @smart_proxy_resource.instance_variable_get(:@resource).instance_variable_get(:@url)
    return @smart_proxy_resource
  end

  def smart_proxy=(smart_proxy_resource)
    return @smart_proxy_resource = smart_proxy_resource if smart_proxy_resource.is_a? Dcim::SmartProxyApi
    raise Dcim::InvalidSmartProxyError
  end

  def fru_list
    freeipmi_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).fru.list)
  end

  def shutdown
    ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).chassis.power.soft, method: :put)
  end

  def power_off
    ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).chassis.power.off, method: :put)
  end

  def power_on_pxe(persistent: true)
    ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).chassis.config.bootdevice.pxe, payload: {reboot: true, persistent: persistent}, method: :put)
  end

  def power_on
    ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).chassis.power.on, method: :put)
  end

  def power_on?
    case ipmitool_smart_proxy_bmc_request(smart_proxy.bmc(self.ip_address).chassis.power.status)
      when "on"
        return true
      when "off"
        return false
      else
        raise Dcim::UnsupportedApiResponseError
    end
  end

  private

  def logger
    @logger ||= Rails.logger
  end

  def foreman_resource
    @foreman_resource ||= Dcim::ForemanApiFactory.instance
  end

  def freeipmi_smart_proxy_bmc_request(query, payload: {}, method: :get)
    http_smart_proxy_bmc_request(query, payload: {'bmc_provider':'freeipmi'}.merge(payload), method: method)
  rescue Dcim::UnknownError
    http_smart_proxy_bmc_request(query, payload: {'bmc_provider':'ipmitool'}.merge(payload), method: method)
  end

  def ipmitool_smart_proxy_bmc_request(query, payload: {}, method: :get)
    http_smart_proxy_bmc_request(query, payload: {'bmc_provider':'ipmitool'}.merge(payload), method: method)
  rescue Dcim::UnknownError
    http_smart_proxy_bmc_request(query, payload: {'bmc_provider':'freeipmi'}.merge(payload), method: method)
  end

  def http_smart_proxy_bmc_request(query, payload: nil, method: :get)
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
      freeipmi_error = result[""] if result.keys.length == 1
      unless freeipmi_error.nil?
        raise Dcim::InvalidUsernameError if freeipmi_error.value? "username invalid"
        raise Dcim::InvalidPasswordError if freeipmi_error.value? "password invalid"
        raise Dcim::ConnectionTimeoutError if freeipmi_error.value? "connection timeout"
        raise Dcim::SessionTimeoutError if freeipmi_error.value? "session timeout"
        raise Dcim::BmcBusyError if freeipmi_error.value? "BMC busy"
        raise Dcim::SdrCacheError if freeipmi_error.value? "Please flush the cache and regenerate it"
        raise Dcim::UnsupportedApiResponseError if freeipmi_error.value? "missing argument"
        # ¯\_(ツ)_/¯ 
        raise Dcim::UnknownError, result
      end
    end
    # freeipmi: "string"
    if result.is_a? String
      raise Dcim::InvalidUsernameError if result == "username invalid"
      raise Dcim::InvalidPasswordError if result == "password invalid"
      raise Dcim::ConnectionTimeoutError if result == "connection timeout"
      raise Dcim::SessionTimeoutError if result == "session timeout"
      raise Dcim::BmcBusyError if result == "BMC busy"
      raise Dcim::SdrCacheError if result == "Please flush the cache and regenerate it"
      raise Dcim::UnsupportedApiResponseError if result.include? "missing argument"
    end
    # All other failures, including ipmitool, which provides no error messages
    if !result
      raise Dcim::UnknownError
    end
    result
  end

  def deep_find(key, object=self, found=nil)
    if object.respond_to?(:key?) && object.key?(key)
      return object[key]
    elsif object.is_a? Enumerable
      object.find { |*a| found = deep_find(key, a.last) }
      return found
    end
  end

  def get_model_and_serial_from_fru_list(fru_list)
    brand = deep_find('board_manufacturer', fru_list) ||
            deep_find('board_mfg', fru_list)
    product = deep_find('product_part/model_number', fru_list) ||
              deep_find('product_name', fru_list) ||
              deep_find('board_product_name', fru_list)
    serial = deep_find('product_serial_number', fru_list)
    raise Dcim::UnsupportedFruError, fru_list if !brand
    # TODO: Modify this model to store brand and product separately
    # so that we can isolate brand and product
    return "#{brand} #{product}", serial
  end

  def validate_correct_credentials
    logger.debug "Validating credentials..."
    unless self.username_changed? or self.password_changed?
      logger.debug "Skipping validation; no change in credentials"
      return true
    end
    if self.username.nil? and self.password.nil?
      logger.debug "No credentials to validate"
      return true
    end
    @smart_proxy_resource ||= get_onboard_smart_proxy
    freeipmi_smart_proxy_bmc_request(@smart_proxy_resource.bmc(self.ip_address).chassis.power.status)
    logger.debug "Credentials validated"
    return true
#  rescue Dcim::SmartProxyError
#    errors.add(:username, "cannot be validated because no suitable Smart Proxy can be reached")
#    errors.add(:password, "cannot be validated because no suitable Smart Proxy can be reached")
#  rescue Dcim::ConnectionTimeoutError
#    errors.add(:username, "cannot be validated because BMC host timed out")
#    errors.add(:password, "cannot be validated because BMC host timed out")
#  rescue Dcim::InvalidUsernameError
#    errors.add(:username, "is not correct")
#    errors.add(:password, "cannot be validated because username is not correct")
#  rescue Dcim::InvalidPasswordError
#    errors.add(:password, "is not correct")
#  rescue Dcim::InvalidCredentialsError
#    errors.add(:username, "and/or password is not correct")
#    errors.add(:password, "and/or username is not correct")
#  rescue Dcim::UnknownError
#    errors.add(:username, "cannot be validated because of an unexpected API response")
#    errors.add(:password, "cannot be validated because of an unexpected API response")
#  rescue RuntimeError
#    errors.add(:username, "cannot be validated because of a RuntimeError")
#    errors.add(:password, "cannot be validated because of a RuntimeError")
  end

end
