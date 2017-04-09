class BmcScanJob < ApplicationRecord
  has_many :bmc_hosts, through: :bmc_scan_job_hosts
  has_one :brute_list
  after_save :update_view, if: :status_changed?
  after_commit :update_view, on: :destroy
  validates :start_address, :end_address, presence: true

  def update_view
    MessageBroadcastJob.perform_now self
  end
end
