class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :components do |t|
      t.string :type
      t.string :label
      t.boolean :managed, null: false, default: true
      t.references :parent, foreign_key: { to_table: :components }

      t.timestamps
    end

    create_table :component_drivers do |t|
      t.references :component, foreign_key: true
      t.string :name
      t.string :secret
      t.boolean :active

      t.timestamps
    end

    create_table :component_properties do |t|
      t.references :component, foreign_key: true
      t.string :key
      t.string :value

      t.timestamps
    end

    create_table :component_links do |t|
      t.references :component, foreign_key: { to_table: :components }
      t.references :linked_component, foreign_key: { to_table: :components }

      t.integer :status

      t.timestamps
    end
  end
end
