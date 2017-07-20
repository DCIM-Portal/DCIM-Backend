class RenameScanStatusToSyncStatusInBmcHosts < ActiveRecord::Migration[5.1]
  def change
    change_table :bmc_hosts do |table|
      table.rename :scan_status, :sync_status
    end
  end
end
