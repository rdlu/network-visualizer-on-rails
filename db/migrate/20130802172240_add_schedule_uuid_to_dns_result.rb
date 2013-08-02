class AddScheduleUuidToDnsResult < ActiveRecord::Migration
  def change
      add_column :dns_results, :schedule_uuid, 'uuid'
  end
end
