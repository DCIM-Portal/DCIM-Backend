class AddNameToZone < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :name, :string
    add_index :zones, :name, unique: true
  end
end
