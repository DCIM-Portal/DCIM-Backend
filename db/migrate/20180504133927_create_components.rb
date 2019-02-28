class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :components do |t|
      t.string :type
      t.string :identifier
      t.boolean :active
      t.string :driver
      t.references :parent, foreign_key: { to_table: :components }

      t.timestamps
    end

    create_table :component_secrets do |t|
      t.string :username
      t.string :password
      t.references :component, foreign_key: true

      t.timestamps
    end

    create_table :component_properties do |t|
      t.references :component, foreign_key: true
      t.string :property_key
      t.string :property_value

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
