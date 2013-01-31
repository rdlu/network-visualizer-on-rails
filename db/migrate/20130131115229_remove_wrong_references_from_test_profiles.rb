class RemoveWrongReferencesFromTestProfiles < ActiveRecord::Migration
  def change
    remove_foreign_key :test_profiles, :metrics
    remove_column :test_profiles, :metric_id
  end
end
