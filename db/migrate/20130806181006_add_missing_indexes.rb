class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :probes, :plan_id
    add_index :probes, :connection_profile_id
    add_index :schedules, [:destination_id, :source_id]
    add_index :schedules, :destination_id
    add_index :schedules, :source_id
    add_index :roles_users, [:user_id, :role_id]
    add_index :roles_users, [:role_id, :user_id]
    add_index :evaluations, :schedule_id
    add_index :evaluations, :profile_id
    add_index :evaluations, [:profile_id, :schedule_id]
    add_index :kpis, :schedule_id
    add_index :thresholds, :connection_profile_id
    add_index :thresholds, :metric_id
    add_index :metrics_profiles, [:profile_id, :metric_id]
    add_index :metrics_profiles, [:metric_id, :profile_id]
    add_index :plans, :connection_profile_id
    add_index :profiles, :connection_profile_id
  end
end