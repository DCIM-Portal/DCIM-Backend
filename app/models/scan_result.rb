class ScanResult < ApplicationRecord

  belongs_to :ilo_scan_job
  after_save :update_view_detail

  private

  def update_view_detail
    DetailBroadcastJob.perform_now self
  end

end
