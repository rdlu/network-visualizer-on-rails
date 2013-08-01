class AddStatusToDnsResult < ActiveRecord::Migration
  def change
    add_column :dns_results, :status, :string
  end
end
