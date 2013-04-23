class CreateDnsDetails < ActiveRecord::Migration
  def change
    create_table :dns_details do |t|
      t.float :efic
      t.float :average
      t.integer :timeout_errors
      t.integer :server_failure_errors
      t.column :uuid, 'uuid'

      t.timestamps
    end
  end
end
