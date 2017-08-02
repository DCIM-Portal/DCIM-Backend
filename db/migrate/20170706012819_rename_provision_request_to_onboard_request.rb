class RenameProvisionRequestToOnboardRequest < ActiveRecord::Migration[5.1]
  def change
    rename_table :provision_requests, :onboard_requests
    rename_column :bmc_hosts, :is_discovered, :is_onboarded
  end
end
