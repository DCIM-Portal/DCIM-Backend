class ReplaceBmcHostIsOnboardedWithSystemId < ActiveRecord::Migration[5.1]
  def change
    rename_column :bmc_hosts, :is_onboarded, :system_id
  end
end
