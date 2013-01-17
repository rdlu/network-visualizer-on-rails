class CreateConnectionProfiles < ActiveRecord::Migration
  def change
    create_table :connection_profiles do |t|
      t.string :name
      t.string :description
      t.string :type

      t.timestamps
    end
  end
end
