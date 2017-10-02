# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_171_002_182_830) do
  create_table 'bmc_hosts', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'serial'
    t.string 'ip_address'
    t.string 'username'
    t.string 'password'
    t.integer 'power_status'
    t.integer 'sync_status'
    t.bigint 'system_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'zone_id'
    t.text 'error_message'
    t.string 'brand'
    t.string 'product'
    t.integer 'onboard_status'
    t.integer 'onboard_step'
    t.text 'onboard_error_message'
    t.datetime 'onboard_updated_at'
    t.index ['ip_address'], name: 'index_bmc_hosts_on_ip_address', unique: true
    t.index ['serial'], name: 'index_bmc_hosts_on_serial', unique: true
    t.index ['system_id'], name: 'fk_rails_b39890445f'
    t.index ['zone_id'], name: 'index_bmc_hosts_on_zone_id'
  end

  create_table 'bmc_scan_request_hosts', id: false, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.bigint 'bmc_scan_request_id'
    t.bigint 'bmc_host_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['bmc_host_id'], name: 'index_bmc_scan_request_hosts_on_bmc_host_id'
    t.index ['bmc_scan_request_id'], name: 'index_bmc_scan_request_hosts_on_bmc_scan_request_id'
  end

  create_table 'bmc_scan_requests', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'name'
    t.string 'start_address'
    t.string 'end_address'
    t.integer 'status'
    t.string 'error_message'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'brute_list_id'
    t.bigint 'zone_id'
    t.index ['brute_list_id'], name: 'index_bmc_scan_requests_on_brute_list_id'
    t.index ['name'], name: 'index_bmc_scan_requests_on_name', unique: true
    t.index ['zone_id'], name: 'index_bmc_scan_requests_on_zone_id'
  end

  create_table 'brute_list_secrets', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'username'
    t.string 'password'
    t.integer 'order'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'brute_list_id'
    t.index ['brute_list_id'], name: 'index_brute_list_secrets_on_brute_list_id'
  end

  create_table 'brute_lists', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_brute_lists_on_name', unique: true
  end

  create_table 'device_links', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'device_id'
    t.bigint 'linked_device_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['device_id'], name: 'index_device_links_on_device_id'
    t.index ['linked_device_id'], name: 'index_device_links_on_linked_device_id'
  end

  create_table 'devices', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'target_type'
    t.bigint 'target_id'
    t.bigint 'enclosure_id'
    t.integer 'order'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['enclosure_id'], name: 'index_devices_on_enclosure_id'
    t.index %w[target_type target_id], name: 'index_devices_on_target_type_and_target_id'
  end

  create_table 'enclosure_racks', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name'
    t.integer 'height'
    t.integer 'x'
    t.integer 'y'
    t.integer 'orientation'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'zone_id'
    t.index ['zone_id'], name: 'index_enclosure_racks_on_zone_id'
  end

  create_table 'enclosures', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer 'u_lower'
    t.integer 'u_upper'
    t.bigint 'enclosure_rack_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['enclosure_rack_id'], name: 'index_enclosures_on_enclosure_rack_id'
  end

  create_table 'onboard_request_bmc_hosts', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.bigint 'bmc_host_id'
    t.bigint 'onboard_request_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['bmc_host_id'], name: 'index_onboard_request_bmc_hosts_on_bmc_host_id'
    t.index ['onboard_request_id'], name: 'index_onboard_request_bmc_hosts_on_onboard_request_id'
  end

  create_table 'onboard_requests', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.integer 'status'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.text 'error_message'
  end

  create_table 'systems', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string 'name'
    t.bigint 'foreman_host_id'
    t.string 'cpu_model'
    t.integer 'cpu_cores'
    t.integer 'cpu_threads'
    t.integer 'cpu_count'
    t.bigint 'ram_total'
    t.bigint 'disk_total'
    t.integer 'disk_count'
    t.string 'os'
    t.string 'os_release'
    t.integer 'sync_status'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.text 'error_message'
    t.index ['foreman_host_id'], name: 'index_systems_on_foreman_host_id', unique: true
    t.index ['name'], name: 'index_systems_on_name'
  end

  create_table 'zones', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name'
    t.bigint 'foreman_location_id'
    t.index ['foreman_location_id'], name: 'index_zones_on_foreman_location_id', unique: true
    t.index ['name'], name: 'index_zones_on_name', unique: true
  end

  add_foreign_key 'bmc_hosts', 'systems'
  add_foreign_key 'bmc_hosts', 'zones'
  add_foreign_key 'bmc_scan_request_hosts', 'bmc_hosts'
  add_foreign_key 'bmc_scan_request_hosts', 'bmc_scan_requests'
  add_foreign_key 'bmc_scan_requests', 'brute_lists'
  add_foreign_key 'bmc_scan_requests', 'zones'
  add_foreign_key 'brute_list_secrets', 'brute_lists'
  add_foreign_key 'device_links', 'devices'
  add_foreign_key 'device_links', 'devices', column: 'linked_device_id'
  add_foreign_key 'devices', 'enclosures'
  add_foreign_key 'enclosure_racks', 'zones'
  add_foreign_key 'enclosures', 'enclosure_racks'
  add_foreign_key 'onboard_request_bmc_hosts', 'bmc_hosts'
  add_foreign_key 'onboard_request_bmc_hosts', 'onboard_requests'
end
