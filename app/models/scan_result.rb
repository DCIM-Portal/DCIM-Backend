class ScanResult < ApplicationRecord

  belongs_to :ilo_scan_job
  after_save :update_view_detail

  enum provision_steps: {
    none: 0,
    in_progress: 1,
    timeout: 2,
    error: 3,
    task_complete: 4
  }

  enum provision_steps_status: {
    initial_scan: 0,
    shutdown: 1,
    poweroff: 2,
    poweron_pxe: 3,
    discover: 4,
    in_backend: 5
  }

  private

  def update_view_detail
    DetailBroadcastJob.perform_now self
  end

end
