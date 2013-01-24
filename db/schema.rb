# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130123132912) do

  create_table "connection_profiles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "notes"
  end

  add_index "connection_profiles", ["name"], :name => "index_connection_profiles_on_name", :unique => true

  create_table "metrics", :force => true do |t|
    t.string   "name"
    t.string   "plugin"
    t.string   "description"
    t.boolean  "reverse"
    t.integer  "order"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "metrics", ["name"], :name => "index_metrics_on_name", :unique => true

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "throughputDown"
    t.integer  "connection_profile_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "throughputUp"
  end

  add_index "plans", ["connection_profile_id"], :name => "plans_connection_profile_id_fk"
  add_index "plans", ["name"], :name => "index_plans_on_name", :unique => true

  create_table "probes", :force => true do |t|
    t.string   "name",                                         :null => false
    t.string   "ipaddress",                                    :null => false
    t.text     "description"
    t.integer  "status",                :default => 0,         :null => false
    t.string   "type",                  :default => "android"
    t.text     "address"
    t.text     "pre_address"
    t.float    "latitude",              :default => 0.0
    t.float    "longitude",             :default => 0.0
    t.integer  "plan_id"
    t.integer  "connection_profile_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "city",                                         :null => false
    t.string   "state",                                        :null => false
  end

  add_index "probes", ["connection_profile_id"], :name => "probes_connection_profile_id_fk"
  add_index "probes", ["ipaddress"], :name => "index_probes_on_ipaddress", :unique => true
  add_index "probes", ["name"], :name => "index_probes_on_name", :unique => true
  add_index "probes", ["plan_id"], :name => "probes_plan_id_fk"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "roles_users_role_id_fk"
  add_index "roles_users", ["user_id"], :name => "roles_users_user_id_fk"

  create_table "test_profiles", :force => true do |t|
    t.string   "name"
    t.text     "config_parameters"
    t.string   "config_method"
    t.integer  "connection_profile_id"
    t.integer  "metric_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "test_profiles", ["connection_profile_id"], :name => "test_profiles_connection_profile_id_fk"
  add_index "test_profiles", ["metric_id"], :name => "test_profiles_metric_id_fk"

  create_table "thresholds", :force => true do |t|
    t.string   "name"
    t.float    "compliance_level",      :default => 0.85,       :null => false
    t.string   "compliance_period",     :default => "monthly",  :null => false
    t.string   "compliance_method",     :default => "standard", :null => false
    t.float    "goal_level",                                    :null => false
    t.string   "goal_period",           :default => "daily",    :null => false
    t.string   "goal_method",           :default => "median",   :null => false
    t.integer  "connection_profile_id"
    t.integer  "metric_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "thresholds", ["connection_profile_id"], :name => "thresholds_connection_profile_id_fk"
  add_index "thresholds", ["metric_id"], :name => "thresholds_metric_id_fk"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "adm_block",              :default => 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  add_foreign_key "plans", "connection_profiles", :name => "plans_connection_profile_id_fk"

  add_foreign_key "probes", "connection_profiles", :name => "probes_connection_profile_id_fk"
  add_foreign_key "probes", "plans", :name => "probes_plan_id_fk"

  add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk"

  add_foreign_key "test_profiles", "connection_profiles", :name => "test_profiles_connection_profile_id_fk"
  add_foreign_key "test_profiles", "metrics", :name => "test_profiles_metric_id_fk"

  add_foreign_key "thresholds", "connection_profiles", :name => "thresholds_connection_profile_id_fk"
  add_foreign_key "thresholds", "metrics", :name => "thresholds_metric_id_fk"

end
