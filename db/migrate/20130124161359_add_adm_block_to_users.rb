class AddAdmBlockToUsers < ActiveRecord::Migration
  def change
    add_column :users, :adm_block, :boolean, :default => true
  end
end
