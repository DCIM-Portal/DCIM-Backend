class AddErrorMessageToSystem < ActiveRecord::Migration[5.1]
  def change
    add_column :systems, :error_message, :text
  end
end
