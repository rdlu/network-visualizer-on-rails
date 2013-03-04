class CreateQuotients < ActiveRecord::Migration
  def change
    create_table :quotients do |t|
      t.references :schedule
      t.references :threshold
      t.string :schedule_uuid
      t.datetime :start_timestamp
      t.datetime :end_timestamp
      t.integer :expected_days
      t.integer :total_days
      t.float :download
      t.float :upload

      t.timestamps
    end
    add_index :quotients, :schedule_id
    add_index :quotients, :threshold_id
  end
end
