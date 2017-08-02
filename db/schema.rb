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

ActiveRecord::Schema.define(version: 20170802191259) do

  create_table "bmc_hosts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "serial"
    t.string "ip_address"
    t.string "username"
    t.string "password"
    t.integer "power_status"
    t.integer "sync_status"
    t.integer "system_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "system_model"
    t.integer "zone_id"
    t.text "error_message"
    t.index ["ip_address"], name: "index_bmc_hosts_on_ip_address", unique: true
    t.index ["serial"], name: "index_bmc_hosts_on_serial", unique: true
    t.index ["zone_id"], name: "index_bmc_hosts_on_zone_id"
  end

  create_table "bmc_scan_request_hosts", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "bmc_scan_request_id"
    t.integer "bmc_host_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bmc_host_id"], name: "index_bmc_scan_request_hosts_on_bmc_host_id"
    t.index ["bmc_scan_request_id"], name: "index_bmc_scan_request_hosts_on_bmc_scan_request_id"
  end

  create_table "bmc_scan_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "start_address"
    t.string "end_address"
    t.integer "status"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "brute_list_id"
    t.integer "zone_id"
    t.index ["brute_list_id"], name: "index_bmc_scan_requests_on_brute_list_id"
    t.index ["name"], name: "index_bmc_scan_requests_on_name", unique: true
    t.index ["zone_id"], name: "index_bmc_scan_requests_on_zone_id"
  end

  create_table "brute_list_secrets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.string "password"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "brute_list_id"
    t.index ["brute_list_id"], name: "index_brute_list_secrets_on_brute_list_id"
  end

  create_table "brute_lists", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brute_lists_on_name", unique: true
  end

  create_table "onboard_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "status"
    t.integer "step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bmc_host_id"
    t.text "error_message"
    t.index ["bmc_host_id"], name: "index_onboard_requests_on_bmc_host_id"
  end

  create_table "systems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "foreman_host_id"
    t.string "cpu_model"
    t.integer "cpu_cores"
    t.integer "cpu_threads"
    t.integer "cpu_count"
    t.bigint "ram_total"
    t.bigint "disk_total"
    t.integer "disk_count"
    t.string "os"
    t.string "os_release"
    t.integer "sync_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foreman_host_id"], name: "index_systems_on_foreman_host_id", unique: true
    t.index ["name"], name: "index_systems_on_name"
  end

  create_table "zones", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "foreman_location_id"
    t.index ["name"], name: "index_zones_on_name", unique: true
  end

end
