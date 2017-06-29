class ProvisionRequest < ApplicationRecord
  belongs_to :bmc_hosts
  enum step: {
    queued: 0,
    shutdown: 1,
    power_off: 2,
    pxe: 3,
    discover: 4
  }
  enum status: {
    nothing: 0,
    in_progress: 1,
    timeout: 2,
    error: 3,
    complete: 4
  }
end
