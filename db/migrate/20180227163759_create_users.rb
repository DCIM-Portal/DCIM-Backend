class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :refresh_tokens do |t|
      t.string :token
      t.string :data
      t.datetime :expire_at
      t.timestamps
    end

    add_index :refresh_tokens, :token, unique: true
    add_index :refresh_tokens, :expire_at
  end
end
