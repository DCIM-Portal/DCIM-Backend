class Zone < ApplicationRecord
  has_many :bmc_hosts
  has_many :bmc_scan_jobs
end
