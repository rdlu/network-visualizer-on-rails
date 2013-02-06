class RenameMetricsTestProfilesToMetricsProfiles < ActiveRecord::Migration
  def up
    remove_foreign_key :metrics_test_profiles, column: :test_profile_id
    rename_column :metrics_test_profiles, :test_profile_id, :profile_id
    add_foreign_key :metrics_test_profiles, :profiles
    rename_table :metrics_test_profiles, :metrics_profiles
  end

  def down
    remove_foreign_key :metrics_profiles, column: :profile_id
    rename_column :metrics_profiles, :profile_id, :test_profile_id
    add_foreign_key :metrics_profiles, :test_profiles
    rename_table :metrics_profiles, :metrics_test_profiles
  end
end
