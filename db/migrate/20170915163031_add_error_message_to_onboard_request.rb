class AddErrorMessageToOnboardRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :onboard_requests, :error_message, :text
  end
end
