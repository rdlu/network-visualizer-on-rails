class AddScheduleUuidToDnsDetail < ActiveRecord::Migration
  def change
      add_column :dns_details, :schedule_uuid, 'uuid'
  end
end
