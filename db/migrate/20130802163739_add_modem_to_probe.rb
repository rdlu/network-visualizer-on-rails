class AddModemToProbe < ActiveRecord::Migration
  def change
    add_column :probes, :modem, :string
  end
end
