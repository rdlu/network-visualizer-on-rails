class CreateMedians < ActiveRecord::Migration
  def change
    create_table :medians do |t|
      t.references :schedule
      t.references :threshold
      t.string :schedule_uuid
      t.datetime :start_timestamp
      t.datetime :end_timestamp
      t.integer :expected_points
      t.integer :total_points
      t.float :dsavg
      t.float :sdavg

      t.timestamps
    end
    add_index :medians, :schedule_id
    add_index :medians, :metric_id
  end
end
