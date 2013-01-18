class Metric < ActiveRecord::Base
  attr_accessible :description, :name, :order, :plugin, :reverse

  validates :name, :presence => true, :length => {:maximum => 30, :minimum => 3}, :uniqueness => true
  validates :plugin, :presence => true, :length => {:maximum => 20, :minimum => 3}, :uniqueness => true,
            :format => {:with => /[a-z0-9]+/}

  has_many :test_profiles
  has_many :thresholds
end
