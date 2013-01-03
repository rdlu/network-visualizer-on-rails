class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :name, :null => false
      t.string :ipadress,:null => false
      t.integer :polling, :null => false
      t.integer :status, :null => false
      t.integer :type, :null => false
      t.string :zip, :null => false
      t.string :adress, :null => false
      t.string :adressnum, :null => false
      t.string :district, :null => false
      t.string :city, :null => false
      t.string :state, :null => false
      t.string :latitude, :null => false
      t.string :longitude, :null => false
      t.boolean :isAndroid,:null => false
      t.timestamps
    end
  end
end
