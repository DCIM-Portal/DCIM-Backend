class Zone < ApplicationRecord
  has_many :bmc_hosts, :autosave => true, :dependent => :restrict_with_exception
  has_many :bmc_scan_requests, :autosave => true, :dependent => :restrict_with_exception
  validates :name, presence: true
  validates_uniqueness_of :name
end
