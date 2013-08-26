class AddTimestampToWebLoadResults < ActiveRecord::Migration
    def up
      add_column :web_load_results, :timestamp, :timestamp

      execute <<-SQL
      UPDATE web_load_results SET "timestamp" = "created_at"
      SQL
    end

    def down
      remove_column :web_load_results, :timestamp
    end
end
