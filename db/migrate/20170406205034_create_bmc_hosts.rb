class CreateBmcHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_hosts do |t|
      t.string :serial
      t.string :address
      t.integer :power
      t.integer :is_discovered

      t.timestamps
    end
  end
end
