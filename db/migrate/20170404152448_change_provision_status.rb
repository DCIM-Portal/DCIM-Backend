class ChangeProvisionStatus < ActiveRecord::Migration[5.0]
  def change
    rename_column :scan_results, :provision_status, :provision_steps_status
    change_column :scan_results, :provision_steps_status, :integer
  end
end
