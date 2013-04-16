class CreateWebLoadDynamicTestResults < ActiveRecord::Migration
  def change
    create_table :web_load_dynamic_test_results do |t|
      t.string :url
      t.float :time
      t.float :size
      t.float :throughput
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
