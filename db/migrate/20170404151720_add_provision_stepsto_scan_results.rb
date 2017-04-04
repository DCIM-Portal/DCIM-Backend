class AddProvisionStepstoScanResults < ActiveRecord::Migration[5.0]
  def change
    add_column :scan_results, :provision_steps, :integer
  end
end
