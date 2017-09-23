class BmcScanRequestHost < ApplicationRecord
  belongs_to :bmc_host
  belongs_to :bmc_scan_request
  after_destroy { emit_cable(destroyed: true) }
end
