class RenameConnectionProfileTypeToConnType < ActiveRecord::Migration
 def change
   rename_column :connection_profiles, :type, :conn_type
 end
end
