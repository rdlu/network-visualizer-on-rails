class CreateTestProfiles < ActiveRecord::Migration
  def change
    create_table :test_profiles do |t|
      t.string :name
      t.text :config_parameters
      t.string :config_method

      t.timestamps
    end
  end
end
