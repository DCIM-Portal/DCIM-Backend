class CreateDevices < ActiveRecord::Migration[5.1]
  def change
    create_table :devices do |t|
      t.references :target, polymorphic: true, index: true
      t.references :enclosure, foreign_key: true
      t.integer :order

      t.timestamps
    end
  end
end
