require 'resolv'

class BmcScanRequest < ApplicationRecord
  has_many :bmc_scan_request_hosts
  has_many :bmc_hosts, -> { distinct }, through: :bmc_scan_request_hosts
  enum status: {
    scan_complete: 0,
    in_progress: 1,
    smart_proxy_unreachable: 2,
    invalid_range: 3
  }
  belongs_to :zone
  belongs_to :brute_list
  validates :name, :brute_list_id, :zone_id, presence: true
  validates :start_address, :end_address, presence: true, format: { with: Resolv::IPv4::Regex, message: 'not a valid IPv4 address' }
  validates_uniqueness_of :name

  before_destroy do
    self.bmc_hosts = []
  end
end
