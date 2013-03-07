class Dns < ActiveRecord::Base
  attr_accessible :address, :internal, :name, :primary, :vip
end
