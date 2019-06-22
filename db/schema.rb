# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_04_133927) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "agent_properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id"
    t.string "key"
    t.text "value"
    t.boolean "encrypted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["agent_id"], name: "index_agent_properties_on_agent_id"
    t.index ["created_at"], name: "index_agent_properties_on_created_at"
    t.index ["updated_at"], name: "index_agent_properties_on_updated_at"
  end

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "driver"
    t.string "label"
    t.jsonb "raw_facts"
    t.uuid "delegate_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_agents_on_created_at"
    t.index ["delegate_id"], name: "index_agents_on_delegate_id"
    t.index ["updated_at"], name: "index_agents_on_updated_at"
  end

  create_table "bmc_hosts", id: :serial, force: :cascade do |t|
    t.string "serial"
    t.string "username"
    t.string "password"
    t.integer "power_status"
    t.integer "sync_status"
    t.integer "system_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "zone_id"
    t.text "error_message"
    t.string "brand"
    t.string "product"
    t.integer "onboard_status"
    t.integer "onboard_step"
    t.text "onboard_error_message"
    t.datetime "onboard_updated_at"
    t.binary "ip_address"
    t.index ["ip_address", "zone_id"], name: "index_bmc_hosts_on_ip_address_and_zone_id", unique: true
    t.index ["serial"], name: "index_bmc_hosts_on_serial", unique: true
    t.index ["zone_id"], name: "index_bmc_hosts_on_zone_id"
  end

  create_table "bmc_scan_request_hosts", id: false, force: :cascade do |t|
    t.integer "bmc_scan_request_id"
    t.integer "bmc_host_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bmc_host_id"], name: "index_bmc_scan_request_hosts_on_bmc_host_id"
    t.index ["bmc_scan_request_id"], name: "index_bmc_scan_request_hosts_on_bmc_scan_request_id"
  end

  create_table "bmc_scan_requests", id: :serial, force: :cascade do |t|
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

  create_table "brute_list_secrets", id: :serial, force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "brute_list_id"
    t.index ["brute_list_id"], name: "index_brute_list_secrets_on_brute_list_id"
  end

  create_table "brute_lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brute_lists_on_name", unique: true
  end

  create_table "component_agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "component_id"
    t.uuid "agent_id"
    t.integer "health"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["agent_id"], name: "index_component_agents_on_agent_id"
    t.index ["component_id"], name: "index_component_agents_on_component_id"
    t.index ["created_at"], name: "index_component_agents_on_created_at"
    t.index ["updated_at"], name: "index_component_agents_on_updated_at"
  end

  create_table "component_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "component_id"
    t.uuid "linked_component_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["component_id"], name: "index_component_links_on_component_id"
    t.index ["created_at"], name: "index_component_links_on_created_at"
    t.index ["linked_component_id"], name: "index_component_links_on_linked_component_id"
    t.index ["updated_at"], name: "index_component_links_on_updated_at"
  end

  create_table "component_properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "component_id"
    t.string "key"
    t.text "value"
    t.uuid "source_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["component_id"], name: "index_component_properties_on_component_id"
    t.index ["created_at"], name: "index_component_properties_on_created_at"
    t.index ["source_id"], name: "index_component_properties_on_source_id"
    t.index ["updated_at"], name: "index_component_properties_on_updated_at"
  end

  create_table "components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "label"
    t.boolean "managed", default: true, null: false
    t.uuid "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_components_on_created_at"
    t.index ["parent_id"], name: "index_components_on_parent_id"
    t.index ["updated_at"], name: "index_components_on_updated_at"
  end

  create_table "delegates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.string "url"
    t.text "auth_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_delegates_on_created_at"
    t.index ["updated_at"], name: "index_delegates_on_updated_at"
  end

  create_table "device_links", force: :cascade do |t|
    t.bigint "device_id"
    t.bigint "linked_device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_links_on_device_id"
    t.index ["linked_device_id"], name: "index_device_links_on_linked_device_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.bigint "enclosure_id"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enclosure_id"], name: "index_devices_on_enclosure_id"
    t.index ["target_type", "target_id"], name: "index_devices_on_target_type_and_target_id"
  end

  create_table "enclosure_racks", force: :cascade do |t|
    t.string "name"
    t.integer "height"
    t.integer "x"
    t.integer "y"
    t.integer "orientation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "zone_id"
    t.index ["zone_id"], name: "index_enclosure_racks_on_zone_id"
  end

  create_table "enclosures", force: :cascade do |t|
    t.integer "u_lower"
    t.integer "u_upper"
    t.bigint "enclosure_rack_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enclosure_rack_id"], name: "index_enclosures_on_enclosure_rack_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["updated_at"], name: "index_events_on_updated_at"
  end

  create_table "job_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.jsonb "arguments"
    t.integer "current_step"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_job_runs_on_created_at"
    t.index ["updated_at"], name: "index_job_runs_on_updated_at"
  end

  create_table "loggable_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "loggable_type"
    t.uuid "loggable_id"
    t.uuid "event_id"
    t.index ["event_id"], name: "index_loggable_events_on_event_id"
    t.index ["loggable_type", "loggable_id"], name: "index_loggable_events_on_loggable_type_and_loggable_id"
  end

  create_table "onboard_request_bmc_hosts", force: :cascade do |t|
    t.bigint "bmc_host_id"
    t.bigint "onboard_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bmc_host_id"], name: "index_onboard_request_bmc_hosts_on_bmc_host_id"
    t.index ["onboard_request_id"], name: "index_onboard_request_bmc_hosts_on_onboard_request_id"
  end

  create_table "onboard_requests", force: :cascade do |t|
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error_message"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.string "token"
    t.string "data"
    t.datetime "expire_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expire_at"], name: "index_refresh_tokens_on_expire_at"
    t.index ["token"], name: "index_refresh_tokens_on_token", unique: true
  end

  create_table "systems", force: :cascade do |t|
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
    t.text "error_message"
    t.index ["foreman_host_id"], name: "index_systems_on_foreman_host_id", unique: true
    t.index ["name"], name: "index_systems_on_name"
  end

  create_table "zones", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "foreman_location_id"
    t.bigint "parent_id"
    t.index ["name"], name: "index_zones_on_name", unique: true
    t.index ["parent_id"], name: "index_zones_on_parent_id"
  end

  add_foreign_key "component_links", "components"
  add_foreign_key "component_links", "components", column: "linked_component_id"
  add_foreign_key "component_properties", "agents", column: "source_id"
  add_foreign_key "components", "components", column: "parent_id"
  add_foreign_key "device_links", "devices"
  add_foreign_key "device_links", "devices", column: "linked_device_id"
  add_foreign_key "devices", "enclosures"
  add_foreign_key "enclosure_racks", "zones"
  add_foreign_key "enclosures", "enclosure_racks"
end
