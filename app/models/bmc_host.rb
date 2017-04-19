class BmcHost < ApplicationRecord
  has_many :bmc_scan_jobs, through: :bmc_scan_job_hosts
  has_one :bmc_host_secret
  has_one :provision_job
  enum is_discovered: {
    not_discovered: 0,
    discovered: 1,
    removed: 2
  }
  enum power: {
    off: 0,
    on: 1
  }
end
