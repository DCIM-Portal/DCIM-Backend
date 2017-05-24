class Zone < ApplicationRecord
  has_many :bmc_hosts
  has_many :bmc_scan_jobs
  validates :name, presence: true
  validates_uniqueness_of :name
end
