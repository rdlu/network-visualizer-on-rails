class CreateDynamicReports < ActiveRecord::Migration
  def change
    create_table :dynamic_reports do |t|
      t.float :rtt
      t.float :throughput_udp_down
      t.float :throughput_udp_up
      t.float :throughput_tcp_down
      t.float :throughput_udp_up
      t.float :throughput_http_down
      t.float :throughput_http_up
      t.float :jitter_down
      t.float :jitter_up
      t.float :loss_down
      t.float :loss_up
      t.integer :pom_down
      t.integer :pom_up
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
