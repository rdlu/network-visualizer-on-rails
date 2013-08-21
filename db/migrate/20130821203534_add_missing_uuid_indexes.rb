class AddMissingUuidIndexes < ActiveRecord::Migration
  def change
    add_index :dns_results, :schedule_uuid
    add_index :dns_dynamic_results, :schedule_uuid
    add_index :web_load_dynamic_results, :schedule_uuid
    add_index :web_load_results, :schedule_uuid
    add_index :dns_details, :schedule_uuid
  end
end
