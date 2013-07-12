# coding: utf-8
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


end
