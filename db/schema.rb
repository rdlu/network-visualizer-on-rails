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

ActiveRecord::Schema.define(:version => 20130423164411) do

  create_table "compliances", :force => true do |t|
    t.integer   "schedule_id"
    t.integer   "threshold_id"
    t.string    "schedule_uuid"
    t.timestamp "start_timestamp", :limit => 6
    t.timestamp "end_timestamp",   :limit => 6
    t.integer   "expected_days"
    t.integer   "total_days"
    t.float     "download"
    t.float     "upload"
    t.timestamp "created_at",      :limit => 6, :null => false
    t.timestamp "updated_at",      :limit => 6, :null => false
    t.string    "type"
    t.string    "calc_method"
  end

  add_index "compliances", ["schedule_id"], :name => "index_quotients_on_schedule_id"
  add_index "compliances", ["threshold_id"], :name => "index_quotients_on_threshold_id"

  create_table "connection_profiles", :force => true do |t|
    t.string    "name_id"
    t.string    "name"
    t.string    "conn_type"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
    t.text      "notes"
  end

  add_index "connection_profiles", ["name_id"], :name => "index_connection_profiles_on_name", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",                :default => 0
    t.integer   "attempts",                :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at",     :limit => 6
    t.timestamp "locked_at",  :limit => 6
    t.timestamp "failed_at",  :limit => 6
    t.string    "locked_by"
    t.string    "queue"
    t.timestamp "created_at", :limit => 6,                :null => false
    t.timestamp "updated_at", :limit => 6,                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dns_details", :force => true do |t|
    t.float    "efic"
    t.float    "average"
    t.integer  "timeout_errors"
    t.integer  "server_failure_errors"
    t.string   "uuid",                  :limit => nil
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "dns_dynamic_results", :force => true do |t|
    t.string   "server"
    t.string   "url"
    t.float    "delay"
    t.string   "uuid",       :limit => nil
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "dns_results", :force => true do |t|
    t.string   "server"
    t.string   "url"
    t.integer  "delay"
    t.string   "uuid",       :limit => nil
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "dynamic_results", :force => true do |t|
    t.float    "rtt"
    t.float    "throughput_udp_down"
    t.float    "throughput_udp_up"
    t.float    "throughput_tcp_down"
    t.float    "throughput_http_down"
    t.float    "throughput_http_up"
    t.float    "jitter_down"
    t.float    "jitter_up"
    t.float    "loss_down"
    t.float    "loss_up"
    t.integer  "pom_down"
    t.integer  "pom_up"
    t.string   "uuid",                      :limit => nil
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.float    "dns_efic"
    t.integer  "dns_timeout_errors"
    t.integer  "dns_server_failure_errors"
    t.string   "user"
  end

  create_table "evaluations", :force => true do |t|
    t.integer   "schedule_id"
    t.integer   "profile_id"
    t.timestamp "created_at",  :limit => 6, :null => false
    t.timestamp "updated_at",  :limit => 6, :null => false
  end

  create_table "kpis", :force => true do |t|
    t.string    "schedule_uuid",    :limit => nil
    t.string    "uuid",             :limit => nil
    t.integer   "destination_id"
    t.integer   "source_id"
    t.integer   "schedule_id"
    t.timestamp "timestamp",        :limit => 6
    t.string    "source_name"
    t.string    "destination_name"
    t.string    "lac"
    t.string    "cell_id"
    t.string    "brand"
    t.string    "model"
    t.string    "conn_type"
    t.string    "conn_tech"
    t.string    "signal"
    t.string    "error_rate"
    t.integer   "change_of_ips"
    t.integer   "mtu"
    t.integer   "dns_latency"
    t.text      "route"
    t.timestamp "created_at",       :limit => 6,   :null => false
    t.timestamp "updated_at",       :limit => 6,   :null => false
  end

  add_index "kpis", ["destination_id"], :name => "index_kpis_on_destination_id"
  add_index "kpis", ["source_id"], :name => "index_kpis_on_source_id"
  add_index "kpis", ["uuid"], :name => "index_kpis_on_uuid"

  create_table "medians", :force => true do |t|
    t.integer   "schedule_id"
    t.integer   "threshold_id"
    t.string    "schedule_uuid",   :limit => nil
    t.timestamp "start_timestamp", :limit => 6
    t.timestamp "end_timestamp",   :limit => 6
    t.integer   "expected_points"
    t.integer   "total_points"
    t.float     "dsavg"
    t.float     "sdavg"
    t.timestamp "created_at",      :limit => 6,   :null => false
    t.timestamp "updated_at",      :limit => 6,   :null => false
    t.string    "type"
  end

  add_index "medians", ["schedule_id"], :name => "index_medians_on_schedule_id"
  add_index "medians", ["threshold_id"], :name => "index_medians_on_threshold_id"

  create_table "metrics", :force => true do |t|
    t.string    "name"
    t.string    "plugin"
    t.string    "description"
    t.boolean   "reverse"
    t.integer   "order"
    t.timestamp "created_at",  :limit => 6, :null => false
    t.timestamp "updated_at",  :limit => 6, :null => false
    t.string    "view_unit"
    t.string    "db_unit"
  end

  add_index "metrics", ["name"], :name => "index_metrics_on_name", :unique => true

  create_table "metrics_profiles", :force => true do |t|
    t.integer "metric_id"
    t.integer "profile_id"
  end

  create_table "nameservers", :force => true do |t|
    t.string    "address"
    t.string    "name"
    t.boolean   "primary"
    t.boolean   "vip"
    t.boolean   "internal"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "plans", :force => true do |t|
    t.string    "name"
    t.text      "description"
    t.integer   "throughput_down"
    t.integer   "connection_profile_id"
    t.timestamp "created_at",            :limit => 6, :null => false
    t.timestamp "updated_at",            :limit => 6, :null => false
    t.integer   "throughput_up"
  end

  add_index "plans", ["name"], :name => "index_plans_on_name", :unique => true

  create_table "probes", :force => true do |t|
    t.string    "name",                                                      :null => false
    t.string    "ipaddress",                                                 :null => false
    t.text      "description"
    t.integer   "status",                             :default => 0,         :null => false
    t.string    "type",                               :default => "android"
    t.text      "address"
    t.text      "pre_address"
    t.float     "latitude",                           :default => 0.0
    t.float     "longitude",                          :default => 0.0
    t.integer   "plan_id"
    t.integer   "connection_profile_id"
    t.timestamp "created_at",            :limit => 6,                        :null => false
    t.timestamp "updated_at",            :limit => 6,                        :null => false
    t.string    "city",                                                      :null => false
    t.string    "state",                                                     :null => false
  end

  add_index "probes", ["ipaddress"], :name => "index_probes_on_ipaddress", :unique => true
  add_index "probes", ["name"], :name => "index_probes_on_name", :unique => true

  create_table "profiles", :force => true do |t|
    t.string    "name"
    t.text      "config_parameters"
    t.string    "config_method"
    t.integer   "connection_profile_id"
    t.timestamp "created_at",            :limit => 6, :null => false
    t.timestamp "updated_at",            :limit => 6, :null => false
  end

  create_table "reports", :force => true do |t|
    t.string   "user"
    t.string   "uuid",       :limit => nil
    t.datetime "timestamp"
    t.string   "agent_type"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "results", :force => true do |t|
    t.integer   "schedule_id"
    t.integer   "metric_id"
    t.string    "schedule_uuid", :limit => nil
    t.string    "uuid",          :limit => nil
    t.string    "metric_name"
    t.timestamp "timestamp",     :limit => 6
    t.float     "dsavg"
    t.float     "sdavg"
    t.float     "dsmin"
    t.float     "sdmin"
    t.float     "dsmax"
    t.float     "sdmax"
    t.timestamp "created_at",    :limit => 6,   :null => false
    t.timestamp "updated_at",    :limit => 6,   :null => false
  end

  add_index "results", ["schedule_id", "metric_id", "timestamp"], :name => "index_results_on_schedule_id_and_metric_id_and_timestamp", :unique => true
  add_index "results", ["schedule_uuid"], :name => "index_results_on_schedule_uuid"
  add_index "results", ["uuid"], :name => "index_results_on_uuid"

  create_table "roles", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at",  :limit => 6, :null => false
    t.timestamp "updated_at",  :limit => 6, :null => false
    t.string    "description"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "schedules", :force => true do |t|
    t.timestamp "start",          :limit => 6
    t.timestamp "end",            :limit => 6
    t.integer   "polling"
    t.string    "status"
    t.timestamp "created_at",     :limit => 6,   :null => false
    t.timestamp "updated_at",     :limit => 6,   :null => false
    t.string    "uuid",           :limit => nil
    t.integer   "destination_id"
    t.integer   "source_id"
  end

  add_index "schedules", ["uuid"], :name => "index_schedules_on_uuid"

  create_table "sites", :force => true do |t|
    t.string    "url"
    t.boolean   "vip"
    t.timestamp "created_at", :limit => 6, :null => false
    t.timestamp "updated_at", :limit => 6, :null => false
  end

  create_table "thresholds", :force => true do |t|
    t.string    "name"
    t.float     "compliance_level",                   :default => 0.85,       :null => false
    t.string    "compliance_period",                  :default => "monthly",  :null => false
    t.string    "compliance_method",                  :default => "standard", :null => false
    t.float     "goal_level",                                                 :null => false
    t.string    "goal_period",                        :default => "daily",    :null => false
    t.string    "goal_method",                        :default => "median",   :null => false
    t.integer   "connection_profile_id"
    t.integer   "metric_id"
    t.timestamp "created_at",            :limit => 6,                         :null => false
    t.timestamp "updated_at",            :limit => 6,                         :null => false
    t.string    "description"
    t.integer   "base_year"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                               :default => "",   :null => false
    t.string    "encrypted_password",                  :default => "",   :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at", :limit => 6
    t.timestamp "remember_created_at",    :limit => 6
    t.integer   "sign_in_count",                       :default => 0
    t.timestamp "current_sign_in_at",     :limit => 6
    t.timestamp "last_sign_in_at",        :limit => 6
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.string    "confirmation_token"
    t.timestamp "confirmed_at",           :limit => 6
    t.timestamp "confirmation_sent_at",   :limit => 6
    t.string    "unconfirmed_email"
    t.timestamp "created_at",             :limit => 6,                   :null => false
    t.timestamp "updated_at",             :limit => 6,                   :null => false
    t.boolean   "adm_block",                           :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "web_load_dynamic_results", :force => true do |t|
    t.string   "url"
    t.float    "time"
    t.float    "size"
    t.float    "throughput"
    t.string   "uuid",       :limit => nil
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "web_load_results", :force => true do |t|
    t.string   "url"
    t.float    "time"
    t.integer  "size"
    t.float    "throughput"
    t.float    "time_main_domain"
    t.integer  "size_main_domain"
    t.float    "throughput_main_domain"
    t.float    "time_other_domain"
    t.integer  "size_other_domain"
    t.float    "throughput_other_domain"
    t.string   "uuid",                    :limit => nil
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_foreign_key "compliances", "schedules", :name => "compliances_schedule_id_fk", :dependent => :delete
  add_foreign_key "compliances", "thresholds", :name => "compliances_threshold_id_fk", :dependent => :delete

  add_foreign_key "evaluations", "profiles", :name => "tests_profile_id_fk"
  add_foreign_key "evaluations", "schedules", :name => "evaluations_schedule_id_fk", :dependent => :delete

  add_foreign_key "kpis", "probes", :name => "kpis_destination_id_fk", :column => "destination_id"
  add_foreign_key "kpis", "schedules", :name => "kpis_schedule_id_fk", :dependent => :delete

  add_foreign_key "medians", "schedules", :name => "medians_schedule_id_fk", :dependent => :delete
  add_foreign_key "medians", "thresholds", :name => "medians_threshold_id_fk", :dependent => :delete

  add_foreign_key "metrics_profiles", "metrics", :name => "metrics_test_profiles_metric_id_fk"
  add_foreign_key "metrics_profiles", "profiles", :name => "metrics_test_profiles_profile_id_fk"

  add_foreign_key "plans", "connection_profiles", :name => "plans_connection_profile_id_fk"

  add_foreign_key "probes", "connection_profiles", :name => "probes_connection_profile_id_fk"
  add_foreign_key "probes", "plans", :name => "probes_plan_id_fk"

  add_foreign_key "profiles", "connection_profiles", :name => "test_profiles_connection_profile_id_fk"

  add_foreign_key "results", "metrics", :name => "results_metric_id_fkey", :dependent => :delete
  add_foreign_key "results", "schedules", :name => "results_schedule_id_fkey", :dependent => :delete

  add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk"

  add_foreign_key "schedules", "probes", :name => "schedules_destination_id_fk", :column => "destination_id"
  add_foreign_key "schedules", "probes", :name => "schedules_source_id_fk", :column => "source_id"

  add_foreign_key "thresholds", "connection_profiles", :name => "thresholds_connection_profile_id_fk"
  add_foreign_key "thresholds", "metrics", :name => "thresholds_metric_id_fk"

end
