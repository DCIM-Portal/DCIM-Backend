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

ActiveRecord::Schema.define(version: 20170418154542) do

  create_table "bmc_host_secrets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "bmc_host_id"
    t.index ["bmc_host_id"], name: "index_bmc_host_secrets_on_bmc_host_id", using: :btree
  end

  create_table "bmc_hosts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "serial"
    t.string   "ip_address"
    t.integer  "power"
    t.integer  "is_discovered"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "system_model"
  end

  create_table "bmc_scan_job_hosts", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "bmc_scan_job_id"
    t.integer  "bmc_host_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["bmc_host_id"], name: "index_bmc_scan_job_hosts_on_bmc_host_id", using: :btree
    t.index ["bmc_scan_job_id"], name: "index_bmc_scan_job_hosts_on_bmc_scan_job_id", using: :btree
  end

  create_table "bmc_scan_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "start_address"
    t.string   "end_address"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "brute_list_id"
    t.index ["brute_list_id"], name: "index_bmc_scan_jobs_on_brute_list_id", using: :btree
  end

  create_table "brute_list_secrets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "password"
    t.integer  "order"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "brute_list_id"
    t.index ["brute_list_id"], name: "index_brute_list_secrets_on_brute_list_id", using: :btree
  end

  create_table "brute_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provision_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "status"
    t.integer  "step"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "bmc_host_id"
    t.index ["bmc_host_id"], name: "index_provision_jobs_on_bmc_host_id", using: :btree
  end

end
