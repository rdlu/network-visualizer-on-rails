class CreateDns < ActiveRecord::Migration
  def change
    create_table :dns do |t|
      t.string :address
      t.string :name
      t.boolean :vip
      t.boolean :primary
      t.boolean :internal

      t.timestamps
    end
  end
end
