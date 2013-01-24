class RenameConnectionProfileDescriptionToNameId < ActiveRecord::Migration
  def change
    rename_column :connection_profiles, :description, :name_id
  end
end
