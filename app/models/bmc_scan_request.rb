class BmcScanRequest < ApplicationRecord
  has_many :bmc_hosts, through: :bmc_scan_request_hosts
  has_one :brute_list
  enum status: {
    queued: 0,
    in_progress: 1,
    smart_proxy_unreachable: 2,
    invalid_range: 3,
    scan_complete: 4,
    removed: 5
  }
  belongs_to :zone
  belongs_to :brute_list
#after_save :update_view, if: :status_changed?
#after_commit :update_view, on: :destroy
  validates :name, :start_address, :end_address, presence: true

  def update_view
    MessageBroadcastJob.perform_now self
  end
end
