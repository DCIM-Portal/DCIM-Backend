class BmcScanRequestHost < ApplicationRecord
  belongs_to :bmc_host
  belongs_to :bmc_scan_request
end
