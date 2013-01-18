class AddUserKeys < ActiveRecord::Migration
  def change
    add_foreign_key "roles_users", "roles", :name => "roles_users_role_id_fk"
    add_foreign_key "roles_users", "users", :name => "roles_users_user_id_fk"
  end
end
