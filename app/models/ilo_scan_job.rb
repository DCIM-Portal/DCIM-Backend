class IloScanJob < ApplicationRecord
  has_many :scan_results
  after_save :update_view, if: :status_changed?
  after_commit :update_view, on: :destroy

  private

  def update_view
    MessageBroadcastJob.perform_now self
  end

end
