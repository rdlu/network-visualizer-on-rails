class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.references :schedule
      t.references :test_profile

      t.timestamps
    end
  end
end
