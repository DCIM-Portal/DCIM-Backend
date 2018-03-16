require 'resolv'

class BmcHost < ApplicationRecord
  include DeviceTarget
  include BmcDrivers::Ipmi
  include Searchable

  has_many :bmc_scan_request_hosts
  has_many :bmc_scan_requests, -> { distinct }, through: :bmc_scan_request_hosts
  has_many :onboard_request_bmc_hosts
  has_many :onboard_requests, -> { distinct }, through: :onboard_request_bmc_hosts
  enum power_status: {
    off: 0,
    on: 1
  }, _prefix: true
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
  }, _prefix: true
  enum onboard_status: {
    success: 0,
    in_progress: 1,
    stack_trace: 2,
    timeout: 3
  }, _prefix: true
  enum onboard_step: {
    complete: 0,
    shutdown: 1,
    power_off: 2,
    pxe: 3,
    discover: 4,
    manage: 5,
    bmc_creds: 6
  }, _prefix: true
  belongs_to :zone
  belongs_to :system, optional: true
  validate :validate_changed_credentials
  validates :ip_address, presence: true, uniqueness: true, format: { with: Resolv::IPv4::Regex }

  before_save { self.onboard_updated_at = Time.now unless changes.select { |key| key.starts_with?('onboard_') }.empty? }

  def refresh!(secret = nil, pass_exceptions: false)
    secret = secret.as_json if secret.is_a? ApplicationRecord
    if secret.is_a? Hash
      logger.debug 'Secret passed in; using passed in credentials...'
      self.username = secret['username']
      self.password = secret['password']
    end
    self.sync_status = :in_progress
    self.error_message = nil
    save!
    logger.debug 'Getting power status...'
    self.power_status = power_on? ? :on : :off
    logger.debug "Power status is #{power_status}"
    logger.debug 'Getting FRU list...'
    frulist = fru_list
    logger.debug 'Parsing FRU list...'
    self.brand = brand_from_fru_list(frulist)
    self.product = product_from_fru_list(frulist)
    self.serial = serial_from_fru_list(frulist)
    logger.debug "Obtained brand \"#{brand}\", product \"#{product}\", and serial \"#{serial}\""
    logger.debug 'Updating record with obtained information...'
    self.sync_status  = :success
  rescue RuntimeError => e
    raise if pass_exceptions
    commit_exception(e)
    false
  ensure
    save!
    logger.debug 'Record updated!'
  end

  def commit_exception(e)
    self.error_message = e.class.name + ': ' + e.message + "\n" + e.backtrace.join("\n")
    begin
      self.sync_status = e.class.name.demodulize.underscore
    rescue ArgumentError
      self.sync_status = :stack_trace
    end
    save!
  end

  def smart_proxy
    unless @smart_proxy_resource.is_a? Dcim::SmartProxyApi
      logger.debug 'Looking for suitable Smart Proxy...'
      return @smart_proxy_resource = Dcim::SmartProxyApiFactory.instance(zone.foreman_location_id)
    end
    logger.debug 'Reusing existing Smart Proxy: ' + @smart_proxy_resource.instance_variable_get(:@resource).instance_variable_get(:@url)
    @smart_proxy_resource
  end

  def smart_proxy=(smart_proxy_resource)
    raise Dcim::InvalidSmartProxyError unless smart_proxy_resource.is_a? Dcim::SmartProxyApi
    @smart_proxy_resource = smart_proxy_resource
  end

  def validate_onboardable
    raise Dcim::BmcHostIncompleteError, 'serial' unless serial
    raise Dcim::InvalidUsernameError unless username
    raise Dcim::InvalidPasswordError unless password
    if onboard_updated_at
      max = 600
      elapsed = Time.now - onboard_updated_at
      raise Dcim::JobCooldownError, max: max, elapsed: elapsed if (elapsed <= max) && (onboard_status == :in_progress)
    end
    # XXX: Next line is too slow if validating bulk BmcHostsController#onboard_modal
    # validate_correct_credentials
    true
  end

  def forget_onboard!
    attributes = self.class.column_names.select { |key| key.starts_with? 'onboard_' }.zip([]).to_h
    update_columns(attributes)
  end

  attr_writer :logger

  private

  def logger
    @logger ||= Rails.logger
  end

  def foreman_resource
    @foreman_resource ||= Dcim::ForemanApiFactory.instance
  end

  def brand_from_fru_list(fru)
    output =
      deep_find('board_manufacturer', fru) ||
      deep_find('board_mfg', fru) ||
      # HPE ProLiant Gen6
      deep_find('product_manufacturer', fru)
    raise Dcim::UnsupportedFruError, "Couldn't extract brand: " + fru.to_s unless output
    output
  end

  def product_from_fru_list(fru)
    brand = brand_from_fru_list(fru).downcase
    output = if brand == 'ibm'
               deep_find('product_name', fru)
             elsif brand == 'supermicro'
               deep_find('product_part/model_number', fru)
             else
               deep_find('board_product_name', fru) ||
                 deep_find('board_product', fru) ||
                 deep_find('product_name', fru) ||
                 deep_find('product_part/model_number', fru)
             end
    raise Dcim::UnsupportedFruError, "Couldn't extract product: " + fru.to_s unless output
    output
  end

  def serial_from_fru_list(fru)
    output =
      deep_find('product_serial_number', fru) ||
      deep_find('product_serial', fru) ||
      deep_find('chassis_serial_number', fru) ||
      deep_find('chassis_serial', fru) ||
      deep_find('board_serial_number', fru) ||
      deep_find('board_serial', fru)
    raise Dcim::UnsupportedFruError, "Couldn't extract serial: " + fru.to_s unless output
    raise Dcim::BmcHostIncompleteError, 'Serial number is blank' if output.empty?
    output
  end

  def validate_changed_credentials
    logger.debug 'Validating credentials...'
    unless username_changed? || password_changed?
      logger.debug 'Skipping validation; no change in credentials'
      return true
    end
    if username.nil? && password.nil?
      logger.debug 'No credentials to validate'
      return true
    end
    validate_correct_credentials
  end

  def validate_correct_credentials
    test
    logger.debug 'Credentials validated'
    true
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
