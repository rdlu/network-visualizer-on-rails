class AddScheduleFKsToNewResults < ActiveRecord::Migration
  def up
    change_table :dns_results do |t|
      t.references :schedule
    end
    change_table :dns_dynamic_results do |t|
      t.references :schedule
    end
    change_table :web_load_dynamic_results do |t|
      t.references :schedule
    end
    change_table :web_load_results do |t|
      t.references :schedule
    end
    change_table :dns_details do |t|
      t.references :schedule
    end
    
    add_foreign_key :dns_results, :schedules, dependent: :delete
    add_foreign_key :dns_dynamic_results, :schedules, dependent: :delete
    add_foreign_key :web_load_dynamic_results, :schedules, dependent: :delete
    add_foreign_key :web_load_results, :schedules, dependent: :delete
    add_foreign_key :dns_details, :schedules, dependent: :delete

=begin
    remove_index :dns_results, :schedule_uuid
    remove_index :dns_dynamic_results, :schedule_uuid
    remove_index :web_load_dynamic_results, :schedule_uuid
    remove_index :web_load_results, :schedule_uuid
    remove_index :dns_details, :schedule_uuid
=end

=begin
    execute <<-SQL
      UPDATE dns_results SET schedule_id = subquery.id FROM (SELECT schedules.id, schedules.uuid FROM schedules, dns_results where dns_results.schedule_uuid = schedules.uuid) AS subquery WHERE dns_results.schedule_uuid = subquery.uuid;
    SQL

    execute <<-SQL
      UPDATE web_load_results SET schedule_id = subquery.id FROM (SELECT schedules.id, schedules.uuid FROM schedules, web_load_results where web_load_results.schedule_uuid = schedules.uuid) AS subquery WHERE web_load_results.schedule_uuid = subquery.uuid;
    SQL
=end
  end

  def down
    remove_foreign_key 'dns_results', 'schedules'
    remove_foreign_key 'dns_dynamic_results', 'schedules'
    remove_foreign_key 'web_load_dynamic_results', 'schedules'
    remove_foreign_key 'web_load_results', 'schedules'
    remove_foreign_key 'dns_details', 'schedules'

    remove_column :dns_results, :schedules
    remove_column :dns_dynamic_results, :schedules
    remove_column :web_load_dynamic_results, :schedules
    remove_column :web_load_results, :schedules
    remove_column :dns_details, :schedules
  end
end
