class CreateScanResults < ActiveRecord::Migration[5.0]
  def change
    create_table :scan_results do |t|
      t.string :ilo_address
      t.string :server_model
      t.string :server_serial
      t.timestamps
    end
  end
end
