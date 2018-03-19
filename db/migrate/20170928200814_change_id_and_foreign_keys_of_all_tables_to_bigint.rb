class ChangeIdAndForeignKeysOfAllTablesToBigint < ActiveRecord::Migration[5.1]
  def change
    return unless ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
    begin
      ActiveRecord::Base.connection.execute <<-SQL
        SET FOREIGN_KEY_CHECKS=0;
      SQL
    rescue ActiveRecord::StatementInvalid
      Rails.logger.warn('Could not set foreign key checks to false in database backend')
    end

    change_column :bmc_hosts, :id, :bigint, auto_increment: true
    change_column :bmc_scan_requests, :id, :bigint, auto_increment: true
    change_column :brute_list_secrets, :id, :bigint, auto_increment: true
    change_column :brute_lists, :id, :bigint, auto_increment: true
    change_column :onboard_request_bmc_hosts, :id, :bigint, auto_increment: true
    change_column :onboard_requests, :id, :bigint, auto_increment: true
    change_column :systems, :id, :bigint, auto_increment: true
    change_column :zones, :id, :bigint, auto_increment: true
    add_index :zones, :foreman_location_id, unique: true

    change_column :bmc_hosts, :system_id, :bigint
    change_column :bmc_hosts, :zone_id, :bigint
    change_column :bmc_scan_request_hosts, :bmc_scan_request_id, :bigint
    change_column :bmc_scan_request_hosts, :bmc_host_id, :bigint
    change_column :bmc_scan_requests, :brute_list_id, :bigint
    change_column :brute_list_secrets, :brute_list_id, :bigint
    change_column :bmc_scan_requests, :zone_id, :bigint
    change_column :onboard_request_bmc_hosts, :bmc_host_id, :bigint
    change_column :onboard_request_bmc_hosts, :onboard_request_id, :bigint
    change_column :systems, :foreman_host_id, :bigint
    change_column :zones, :foreman_location_id, :bigint

    add_foreign_key :bmc_hosts, :systems
    add_foreign_key :bmc_hosts, :zones
    add_foreign_key :bmc_scan_request_hosts, :bmc_scan_requests
    add_foreign_key :bmc_scan_request_hosts, :bmc_hosts
    add_foreign_key :bmc_scan_requests, :brute_lists
    add_foreign_key :brute_list_secrets, :brute_lists
    add_foreign_key :bmc_scan_requests, :zones
    add_foreign_key :onboard_request_bmc_hosts, :bmc_hosts
    add_foreign_key :onboard_request_bmc_hosts, :onboard_requests
    begin
      ActiveRecord::Base.connection.execute <<-SQL
        SET FOREIGN_KEY_CHECKS=1;
      SQL
    rescue ActiveRecord::StatementInvalid
      Rails.logger.warn('Could not set foreign key checks to true in database backend')
    end
  end
end
