class AddScheduleUuidToWebLoadDynamicResult < ActiveRecord::Migration
  def change
      add_column :web_load_dynamic_results, :schedule_uuid, 'uuid'
  end
end
