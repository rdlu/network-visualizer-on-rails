class CreateNameservers < ActiveRecord::Migration
  def change
    create_table :nameservers do |t|
      t.string :address
      t.string :name
      t.boolean :primary
      t.boolean :vip
      t.boolean :internal

      t.timestamps
    end
  end
end
