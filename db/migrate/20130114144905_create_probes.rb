class CreateProbes < ActiveRecord::Migration
  def change
    create_table :probes do |t|
      t.string :name, :null => false
      t.string :ipaddress, :null => false
      t.text :description
      t.integer :status, :null => false, :default => 0
      t.string :type, :default => 'android'
      t.text :address
      t.text :pre_address
      t.float :latitude, :default => 0
      t.float :longitude, :default => 0

      t.references :plan
      t.references :connection_profile

      t.timestamps
    end

    add_index :probes, :name, :unique => true
    add_index :probes, :ipaddress, :unique => true
  end
end
