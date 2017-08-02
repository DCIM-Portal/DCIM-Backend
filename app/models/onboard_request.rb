class OnboardRequest < ApplicationRecord
  belongs_to :bmc_host
  enum step: {
    complete: 0,
    shutdown: 1,
    power_off: 2,
    pxe: 3,
    discover: 4,
    manage: 5,
    bmc_creds: 6
  }
  enum status: {
    success: 0,
    in_progress: 1,
    stack_trace: 2,
    timeout: 3
  }
end
