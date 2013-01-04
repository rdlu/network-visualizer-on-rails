class CreateThresholdProfiles < ActiveRecord::Migration
  def change
    create_table :threshold_profiles do |t|
      t.string :name
      t.text :desc

      t.timestamps
    end
  end
end
