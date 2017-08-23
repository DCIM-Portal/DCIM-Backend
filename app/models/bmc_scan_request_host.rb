class BmcScanRequestHost < ApplicationRecord
  belongs_to :bmc_host
  belongs_to :bmc_scan_request
  after_destroy { self.emit_cable(destroyed: true) }
  def emit_cable(**kwargs)
    ::LiveViewBroadcastJob.perform_later JSON.parse(self.to_json), **kwargs
  end
end
