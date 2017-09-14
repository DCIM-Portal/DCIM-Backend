class OnboardRequestBmcHost < ApplicationRecord
  belongs_to :bmc_host
  belongs_to :onboard_request
end
