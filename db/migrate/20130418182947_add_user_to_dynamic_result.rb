class AddUserToDynamicResult < ActiveRecord::Migration
  def change
    add_column :dynamic_results, :user, :string
  end
end
