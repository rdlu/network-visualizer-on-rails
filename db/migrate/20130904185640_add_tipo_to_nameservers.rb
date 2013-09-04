class AddTipoToNameservers < ActiveRecord::Migration
  def change
    add_column :nameservers, :type, :string
  end
end
