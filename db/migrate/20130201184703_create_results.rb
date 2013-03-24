class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :schedule
      t.references :metric
      t.column :schedule_uuid, 'uuid'
      t.column :uuid, 'uuid'
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
    add_index :results, :uuid
    add_index :results, :schedule_uuid
    add_index :results, [:schedule_id, :metric_id, :timestamp], :unique => true

    change_table :schedules do |t|
      t.column :uuid, 'uuid'
    end
    add_index :schedules, :uuid
  end
end
