class CreateSystems < ActiveRecord::Migration[5.1]
  def change
    create_table :systems do |t|
      t.string :name
      t.integer :foreman_host_id
      t.string :cpu_model
      t.integer :cpu_cores
      t.integer :cpu_threads
      t.integer :cpu_count
      t.integer :ram_total, limit: 8
      t.integer :disk_total, limit: 8
      t.integer :disk_count
      t.string :os
      t.string :os_release
      t.integer :sync_status

      t.timestamps
    end
    add_index :systems, :name
    add_index :systems, :foreman_host_id, unique: true
  end
end
