class CreateKpis < ActiveRecord::Migration
  def change
    create_table :kpis do |t|
      t.column :schedule_uuid, 'char(32)'
      t.column :uuid, 'char(32)'
      t.references :destination
      t.references :source
      t.references :schedule
      t.timestamp :timestamp
      t.string :source_name
      t.string :destination_name
      t.string :lac
      t.string :cell_id
      t.string :brand
      t.string :model
      t.string :conn_type
      t.string :conn_tech
      t.string :signal
      t.string :error_rate
      t.integer :change_of_ips
      t.integer :mtu
      t.integer :dns_latency
      t.text :route
      t.timestamps
    end
    add_index :kpis, :destination_id
    add_index :kpis, :source_id
    add_index :kpis, :uuid
  end
end
