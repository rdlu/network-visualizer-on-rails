class AddScheduleUuidToWebLoadResult < ActiveRecord::Migration
  def change
      add_column :web_load_results, :schedule_uuid, 'uuid'
  end
end
