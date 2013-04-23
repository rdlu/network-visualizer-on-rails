class CreateDnsResults < ActiveRecord::Migration
  def change
    create_table :dns_results do |t|
      t.string :server
      t.string :url
      t.integer :delay
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
