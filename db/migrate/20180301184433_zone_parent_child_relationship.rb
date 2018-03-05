class ZoneParentChildRelationship < ActiveRecord::Migration[5.2]
  def change
    add_column :zones, :parent_id, :bigint
    add_index :zones, :parent_id
  end
end
