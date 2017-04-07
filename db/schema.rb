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

ActiveRecord::Schema.define(version: 20170406212811) do

  create_table "bmc_hosts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "serial"
    t.string   "ip_address"
    t.integer  "power"
    t.integer  "is_discovered"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "bmc_scan_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "start_address"
    t.string   "end_address"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "brute_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ilo_scan_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "start_ip"
    t.string   "end_ip"
    t.string   "ilo_username"
    t.string   "ilo_password"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "count"
  end

  create_table "provision_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "status"
    t.integer  "step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scan_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "ilo_address"
    t.string   "server_model"
    t.string   "server_serial"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "ilo_scan_job_id"
    t.string   "power_status"
    t.integer  "provision_steps_status"
    t.integer  "provision_steps"
    t.index ["ilo_scan_job_id"], name: "index_scan_results_on_ilo_scan_job_id", using: :btree
  end

  create_table "secrets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "password"
    t.integer  "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
