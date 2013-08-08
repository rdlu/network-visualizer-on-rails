class AddScheduleUuidToDynamicResult < ActiveRecord::Migration
  def change
      add_column :dynamic_results, :schedule_uuid, 'uuid'
  end
end
