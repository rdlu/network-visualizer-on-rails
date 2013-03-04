class AddMethodToCompliances < ActiveRecord::Migration
  def change
    add_column :compliances, :calc_method, :string
  end
end
