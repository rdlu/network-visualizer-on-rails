class RenameTestProfileToProfile < ActiveRecord::Migration
  def up
    rename_table :test_profiles, :profiles
    remove_foreign_key :tests, column: :test_profile_id
    rename_column :tests, :test_profile_id, :profile_id
    add_foreign_key :tests, :profiles
  end

  def down
    rename_table :profiles, :test_profiles
    remove_foreign_key :tests, column: :profile_id
    rename_column :tests, :profile_id, :test_profile_id
    add_foreign_key :tests, :test_profiles
  end
end