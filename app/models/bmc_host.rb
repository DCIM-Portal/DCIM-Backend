class BmcHost < ApplicationRecord
  has_many :bmc_scan_jobs, through: :bmc_scan_job_hosts
  has_one :bmc_host_secret
  has_one :provision_job
end
