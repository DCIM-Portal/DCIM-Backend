class CreateEnclosureRacks < ActiveRecord::Migration[5.1]
  def change
    create_table :enclosure_racks do |t|
      t.string :name
      t.integer :height
      t.integer :x
      t.integer :y
      t.integer :orientation

      t.timestamps
    end
    add_reference :enclosure_racks, :zone, foreign_key: true
  end
end
