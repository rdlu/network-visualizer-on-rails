class AddScheduleUuidToDnsDynamicResult < ActiveRecord::Migration
  def change
      add_column :dns_dynamic_results, :schedule_uuid, 'uuid'
  end
end
