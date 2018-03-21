class OnboardRequest < ApplicationRecord
  has_many :onboard_request_bmc_hosts
  has_many :bmc_hosts, -> { distinct }, through: :onboard_request_bmc_hosts
  enum status: {
    complete: 0,
    in_progress: 1,
    stack_trace: 2
  }

  before_destroy do
    self.bmc_hosts = []
  end
end
