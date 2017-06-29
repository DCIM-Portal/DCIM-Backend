class CreateBmcHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :bmc_hosts do |t|
      t.string :serial
      t.string :ip_address
      t.string :username
      t.string :password
      t.integer :power
      t.integer :is_discovered

      t.timestamps
    end
    add_index :bmc_hosts, :serial, unique: true
    add_index :bmc_hosts, :ip_address, unique: true
  end
end
