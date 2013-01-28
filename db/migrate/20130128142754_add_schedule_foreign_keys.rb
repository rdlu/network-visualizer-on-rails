class AddScheduleForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "schedules", "probes", :name => "schedules_probe_id_fk"
    add_foreign_key "tests", "schedules", :name => "tests_schedule_id_fk"
    add_foreign_key "tests", "test_profiles", :name => "tests_test_profile_id_fk"
  end
end
