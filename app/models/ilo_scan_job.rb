class IloScanJob < ApplicationRecord
  has_many :scan_results
  after_save :update_view, if: :status_changed?

  private

  def update_view
    MessageBroadcastJob.perform_later self
  end

end
