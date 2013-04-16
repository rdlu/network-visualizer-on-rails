class CreateDnsDynamicTestResults < ActiveRecord::Migration
  def change
    create_table :dns_dynamic_test_results do |t|
      t.string :server
      t.string :url
      t.float :delay
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
