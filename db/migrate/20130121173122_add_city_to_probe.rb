class AddCityToProbe < ActiveRecord::Migration
  def change
    add_column :probes, :city, :string, :null => false
    add_column :probes, :state, :string, :null => false
  end
end
