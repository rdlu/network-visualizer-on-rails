# coding: utf-8
# == Schema Information
#
# Table name: nameservers
#
#  id         :integer          not null, primary key
#  address    :string(255)
#  name       :string(255)
#  primary    :boolean
#  vip        :boolean
#  internal   :boolean
#  created_at :timestamp(6)     not null
#  updated_at :timestamp(6)     not null
#

class Nameserver < ActiveRecord::Base
  attr_accessible :address, :internal, :name, :primary, :vip, :type

  validates :address, :presence => true, :length => {:maximum => 255, :minimum => 3}
  validate :validate_address

  @inheritance_column = 'type2'

  def pretty_name
    "#{self.name} (#{self.address})"
  end

  def validate_address
    errors.add('Endereço tem um formato inválido') unless ip?
  end

  def ip?
    !!(IPAddress.valid? self.address)
  end

  def pretty_human_internal
    if self.internal == true
      "Sim"
    else
      "Não"
    end
  end

  def pretty_human_vip
    if self.vip == true
      "Sim"
    else
      "Não"
    end
  end

  def pretty_human_primary
    if self.primary == true
      "Sim"
    else
      "Não"
    end
  end
end
