class AddTimestampToDnsResult < ActiveRecord::Migration
  def up
    add_column :dns_results, :timestamp, :timestamp

    execute <<-SQL
      UPDATE dns_results SET "timestamp" = "created_at"
    SQL
  end

  def down
    remove_column :dns_results, :timestamp
  end
end
