class AddMetricTestProfilesHabtm < ActiveRecord::Migration
  def change
    create_table :metrics_test_profiles do |t|
      t.references :metric
      t.references :test_profile
    end
    add_foreign_key "metrics_test_profiles", "metrics", :name => "metrics_test_profiles_metric_id_fk"
    add_foreign_key "metrics_test_profiles", "test_profiles", :name => "metrics_test_profiles_test_profile_id_fk"
  end
end