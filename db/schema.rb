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

ActiveRecord::Schema.define(:version => 20130304141153) do

  create_table "connection_profiles", :force => true do |t|
    t.string   "name_id"
    t.string   "name"
    t.string   "conn_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "notes"
  end

  add_index "connection_profiles", ["name_id"], :name => "index_connection_profiles_on_name", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "evaluations", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "profile_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "evaluations", ["profile_id"], :name => "tests_profile_id_fk"
  add_index "evaluations", ["schedule_id"], :name => "tests_schedule_id_fk"

  create_table "kpis", :force => true do |t|
    t.string   "schedule_uuid",    :limit => 36
    t.string   "uuid",             :limit => 36
    t.integer  "destination_id"
    t.integer  "source_id"
    t.integer  "schedule_id"
    t.datetime "timestamp"
    t.string   "source_name"
    t.string   "destination_name"
    t.string   "lac"
    t.string   "cell_id"
    t.string   "brand"
    t.string   "model"
    t.string   "conn_type"
    t.string   "conn_tech"
    t.string   "signal"
    t.string   "error_rate"
    t.integer  "change_of_ips"
    t.integer  "mtu"
    t.integer  "dns_latency"
    t.text     "route"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "kpis", ["destination_id"], :name => "index_kpis_on_destination_id"
  add_index "kpis", ["source_id"], :name => "index_kpis_on_source_id"
  add_index "kpis", ["uuid"], :name => "index_kpis_on_uuid"

  create_table "medians", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "threshold_id"
    t.string   "schedule_uuid"
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.integer  "expected_points"
    t.integer  "total_points"
    t.float    "dsavg"
    t.float    "sdavg"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "type"
  end

  add_index "medians", ["schedule_id"], :name => "index_medians_on_schedule_id"
  add_index "medians", ["threshold_id"], :name => "index_medians_on_threshold_id"

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

  create_table "metrics_profiles", :force => true do |t|
    t.integer "metric_id"
    t.integer "profile_id"
  end

  add_index "metrics_profiles", ["metric_id"], :name => "metrics_test_profiles_metric_id_fk"
  add_index "metrics_profiles", ["profile_id"], :name => "metrics_test_profiles_profile_id_fk"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "throughput_down"
    t.integer  "connection_profile_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "throughput_up"
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

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.text     "config_parameters"
    t.string   "config_method"
    t.integer  "connection_profile_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "profiles", ["connection_profile_id"], :name => "test_profiles_connection_profile_id_fk"

  create_table "quotients", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "threshold_id"
    t.string   "schedule_uuid"
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.integer  "expected_days"
    t.integer  "total_days"
    t.float    "download"
    t.float    "upload"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "quotients", ["schedule_id"], :name => "index_quotients_on_schedule_id"
  add_index "quotients", ["threshold_id"], :name => "index_quotients_on_threshold_id"

  create_table "results", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "metric_id"
    t.string   "schedule_uuid", :limit => 36
    t.string   "uuid",          :limit => 36
    t.string   "metric_name"
    t.datetime "timestamp"
    t.float    "dsavg"
    t.float    "sdavg"
    t.float    "dsmin"
    t.float    "sdmin"
    t.float    "dsmax"
    t.float    "sdmax"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "results", ["schedule_id"], :name => "index_results_on_schedule_id"
  add_index "results", ["uuid"], :name => "index_results_on_uuid"

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

  create_table "schedules", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "polling"
    t.string   "status"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "uuid",           :limit => 36
    t.integer  "destination_id"
    t.integer  "source_id"
  end

  add_index "schedules", ["destination_id"], :name => "schedules_destination_id_fk"
  add_index "schedules", ["source_id"], :name => "schedules_source_id_fk"
  add_index "schedules", ["uuid"], :name => "index_schedules_on_uuid"

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
    t.string   "description"
    t.integer  "base_year"
  end

  add_index "thresholds", ["connection_profile_id"], :name => "thresholds_connection_profile_id_fk"
  add_index "thresholds", ["metric_id"], :name => "thresholds_metric_id_fk"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
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
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.boolean  "adm_block",              :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  add_foreign_key "evaluations", "profiles", :name => "tests_profile_id_fk"
  add_foreign_key "evaluations", "schedules", :name => "evaluations_schedule_id_fk", :dependent => :delete

  add_foreign_key "metrics_profiles", "metrics", :name => "metrics_test_profiles_metric_id_fk"
  add_foreign_key "metrics_profiles", "profiles", :name => "metrics_test_profiles_profile_id_fk"

  add_foreign_key "plans", "connection_profiles", :name => "plans_connection_profile_id_fk"

  add_foreign_key "probes", "connection_profiles", :name => "probes_connection_profile_id_fk"
  add_foreign_key "probes", "plans", :name => "probes_plan_id_fk"

  add_foreign_key "profiles", "connection_profiles", :name => "test_profiles_connection_profile_id_fk"

  add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk"

  add_foreign_key "schedules", "probes", :name => "schedules_destination_id_fk", :column => "destination_id"
  add_foreign_key "schedules", "probes", :name => "schedules_source_id_fk", :column => "source_id"

  add_foreign_key "thresholds", "connection_profiles", :name => "thresholds_connection_profile_id_fk"
  add_foreign_key "thresholds", "metrics", :name => "thresholds_metric_id_fk"

end
