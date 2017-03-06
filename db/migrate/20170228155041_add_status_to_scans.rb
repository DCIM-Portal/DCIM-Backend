class AddStatusToScans < ActiveRecord::Migration[5.0]
  def change
    add_column :scan_results, :power_status, :string
    add_column :scan_results, :provision_status, :string
  end
end
