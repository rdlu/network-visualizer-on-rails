class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "plans", "connection_profiles", :name => "plans_connection_profile_id_fk"
    add_foreign_key "probes", "connection_profiles", :name => "probes_connection_profile_id_fk"
    add_foreign_key "probes", "plans", :name => "probes_plan_id_fk"
    add_foreign_key "test_profiles", "connection_profiles", :name => "test_profiles_connection_profile_id_fk"
    add_foreign_key "test_profiles", "metrics", :name => "test_profiles_metric_id_fk"
    add_foreign_key "thresholds", "connection_profiles", :name => "thresholds_connection_profile_id_fk"
    add_foreign_key "thresholds", "metrics", :name => "thresholds_metric_id_fk"
  end
end
