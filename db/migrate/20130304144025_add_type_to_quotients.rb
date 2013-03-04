class AddTypeToQuotients < ActiveRecord::Migration
  def change
    add_column :quotients, :type, :string
  end
end
