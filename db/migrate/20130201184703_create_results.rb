class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :schedule
      t.references :metric
      t.column :schedule_uuid, 'char(36)'
      t.column :uuid, 'char(36)'
      t.string :metric_name
      t.timestamp :timestamp
      t.float :dsavg
      t.float :sdavg
      t.float :dsmin
      t.float :sdmin
      t.float :dsmax
      t.float :sdmax

      t.timestamps
    end
    add_index :results, :schedule_id
    add_index :results, :uuid

    change_table :schedules do |t|
      t.column :uuid, 'char(36)'
    end
    add_index :schedules, :uuid
  end
end
