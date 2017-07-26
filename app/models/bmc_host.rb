class BmcHost < ApplicationRecord
  has_many :bmc_scan_request_hosts
  has_many :bmc_scan_requests, -> { distinct }, through: :bmc_scan_request_hosts
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
  enum sync_status: {
    success: 0,
    unknown_error: 1,
    stack_trace: 2,
    smart_proxy_error: 3,
    connection_timeout_error: 4,
    invalid_credentials_error: 5,
    invalid_username_error: 6,
    invalid_password_error: 7,
    unsupported_fru_error: 8,
    session_timeout_error: 9,
    bmc_busy_error: 10
  }
  belongs_to :zone
end
