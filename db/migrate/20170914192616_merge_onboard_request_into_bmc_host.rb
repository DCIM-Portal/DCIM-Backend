class MergeOnboardRequestIntoBmcHost < ActiveRecord::Migration[5.1]
  def up
    add_column :bmc_hosts, :onboard_status, :integer
    add_column :bmc_hosts, :onboard_step, :integer
    add_column :bmc_hosts, :onboard_error_message, :text
    add_column :bmc_hosts, :onboard_updated_at, :datetime

    OnboardRequest.all.each do |onboard_request|
      onboard_request.bmc_host.onboard_status = onboard_request.status
      onboard_request.bmc_host.onboard_step = onboard_request.step
      onboard_request.bmc_host.onboard_error_message = onboard_request.error_message
      onboard_request.bmc_host.onboard_updated_at = onboard_request.updated_at
      onboard_request.bmc_host.save!
    end

    drop_table :onboard_requests
  end

  def down
    create_table :onboard_requests do |t|
      t.integer :status
      t.integer :step
      t.text :error_message
      t.integer :bmc_host_id

      t.timestamps
    end

    BmcHost.all.each do |bmc_host|
      next unless bmc_host.onboard_status

      onboard_request = OnboardRequest.new
      onboard_request.bmc_host = bmc_host
      onboard_request.status = bmc_host.onboard_status
      onboard_request.step = bmc_host.onboard_step
      onboard_request.error_message = bmc_host.onboard_error_message
      onboard_request.updated_at = bmc_host.onboard_updated_at
      onboard_request.save!
    end

    remove_column :bmc_hosts, :onboard_status
    remove_column :bmc_hosts, :onboard_step
    remove_column :bmc_hosts, :onboard_error_message
    remove_column :bmc_hosts, :onboard_updated_at
  end
end
