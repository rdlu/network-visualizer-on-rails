class AddTotalToDnsDetails < ActiveRecord::Migration
  def change
    add_column :dns_details, :total, :integer
  end
end
