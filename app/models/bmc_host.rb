class BmcHost < ApplicationRecord
  has_many :bmc_scan_request_hosts
  has_many :bmc_scan_requests, through: :bmc_scan_request_hosts
  #has_one :bmc_host_secret
  has_one :provision_request
  enum is_discovered: {
    not_discovered: 0,
    discovered: 1,
    removed: 2
  }
  enum power_status: {
    off: 0,
    on: 1
  }
  enum scan_status: {
    success: 0,
    unknown_error: 1,
    connection_timeout_error: 2,
    invalid_credentials_error: 3,
    invalid_username_error: 4,
    invalid_password_error: 5,
    unsupported_fru_error: 6,
    stack_trace: 7
  }
  belongs_to :zone
end
