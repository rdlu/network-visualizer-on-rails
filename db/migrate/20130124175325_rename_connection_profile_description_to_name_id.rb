class RenameConnectionProfileDescriptionToNameId < ActiveRecord::Migration
  def change
    rename_column :connection_profiles, :name, :name_id
    rename_column :connection_profiles, :description, :name
  end
end
