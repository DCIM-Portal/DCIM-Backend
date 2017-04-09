class BmcScanJobHost < ApplicationRecord
  belongs_to :bmc_host
  belongs_to :bmc_scan_job
end
