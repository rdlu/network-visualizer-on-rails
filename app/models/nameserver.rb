class Nameserver < ActiveRecord::Base
  attr_accessible :address, :internal, :name, :primary, :vip

  def pretty_name
    "#{self.name} (#{self.address})"
  end
end
