class CreateComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :delegates, id: :uuid do |t|
      t.string :label
      t.string :url
      t.text :auth_key

      t.timestamps index: true
    end

    create_table :agents, id: :uuid do |t|
      t.string :driver
      t.string :label
      t.references :delegate, type: :uuid

      t.timestamps index: true
    end

    create_table :agent_properties, id: :uuid do |t|
      t.references :agent, type: :uuid
      t.string :key
      t.text :value
      t.boolean :encrypted, default: false

      t.timestamps index: true
    end

    create_table :component_agents, id: :uuid do |t|
      t.references :component, type: :uuid
      t.references :agent, type: :uuid
      t.integer :health

      t.timestamps index: true
    end

    create_table :components, id: :uuid do |t|
      t.string :type
      t.string :label
      t.boolean :managed, null: false, default: true
      t.references :parent, type: :uuid, foreign_key: { to_table: :components }

      t.timestamps index: true
    end

    create_table :component_properties, id: :uuid do |t|
      t.references :component, type: :uuid
      t.string :key
      t.text :value
      t.references :source, type: :uuid, foreign_key: { to_table: :agents }

      t.timestamps index: true
    end

    create_table :component_links, id: :uuid do |t|
      t.references :component, type: :uuid, foreign_key: { to_table: :components }
      t.references :linked_component, type: :uuid, foreign_key: { to_table: :components }

      t.integer :status

      t.timestamps index: true
    end

    create_table :job_runs, id: :uuid do |t|
      t.string :type
      t.jsonb :arguments
      t.integer :status

      t.timestamps index: true
    end

    create_table :events, id: :uuid do |t|
      t.jsonb :data

      t.timestamps index: true
    end

    create_table :loggable_events, id: :uuid do |t|
      t.references :loggable, type: :uuid, polymorphic: true, index: true
      t.references :event, type: :uuid

      t.timestamps index: true
    end
  end
end
