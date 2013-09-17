class AddTimestampToDnsDetail < ActiveRecord::Migration
  def up
    add_column :dns_details, :timestamp, :timestamp

    execute <<-SQL
      UPDATE dns_details SET "timestamp" = "created_at"
    SQL
  end

  def down
    remove_column :dns_details, :timestamp
  end
end
