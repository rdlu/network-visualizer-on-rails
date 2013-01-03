class CreateProfiles < ActiveRecord::Migration
  def up
    create_table :profiles do |t|
       t.string :name, :null => false
       t.integer :count, :null => false
       t.integer :probeCount, :null => false
       t.integer :probeValue, :null => false
       t.integer :gap, :null => false
       t.integer :timeout, :null => false
       t.integer :polling, :null => false
       t.boolean :protocol, :default => false
       t.boolean :qosType, :default => false
       t.integer :qosValue, :null => false
       t.timestamps
    end
  end

  def down

  end

end
