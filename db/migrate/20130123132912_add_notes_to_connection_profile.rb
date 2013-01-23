class AddNotesToConnectionProfile < ActiveRecord::Migration
  def change
    add_column :connection_profiles, :notes, :text
  end
end
