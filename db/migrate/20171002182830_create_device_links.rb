class CreateDeviceLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :device_links do |t|
      t.references :device, foreign_key: { to_table: :devices }
      t.references :linked_device, foreign_key: { to_table: :devices }

      t.timestamps
    end
  end
end
