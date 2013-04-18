class CreateWebLoadResults < ActiveRecord::Migration
  def change
    create_table :web_load_results do |t|
      t.string :url
      t.float :time
      t.integer :size
      t.float :throughput
      t.float :time_main_domain
      t.integer :size_main_domain
      t.float :throughput_main_domain
      t.float :time_other_domain
      t.integer :size_other_domain
      t.float :throughput_other_domain
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
