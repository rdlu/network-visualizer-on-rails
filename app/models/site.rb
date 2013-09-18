# coding: utf-8
# == Schema Information
#
# Table name: sites
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  vip        :boolean
#  created_at :timestamp(6)     not null
#  updated_at :timestamp(6)     not null
#

class Site < ActiveRecord::Base
  attr_accessible :url, :vip

  validates :url, :presence => true
  validate :validate_url

  def validate_url
    errors.add(:url, ' tem um formato inválido.') unless hostname?
  end

  def hostname?
    !!(self.url.match(/^((?:https?\:\/\/|www\.|)([-a-z0-9]+\.)+[-a-z]+.)$/i))
  end

  def pretty_human_vip
    if self.vip == true
      "Sim"
    else
      "Não"
    end
  end
end
