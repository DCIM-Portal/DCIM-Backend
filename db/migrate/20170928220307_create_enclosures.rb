class CreateEnclosures < ActiveRecord::Migration[5.1]
  def change
    create_table :enclosures do |t|
      t.integer :u_lower
      t.integer :u_upper
      t.references :enclosure_rack, foreign_key: true

      t.timestamps
    end
  end
end
