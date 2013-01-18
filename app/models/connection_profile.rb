class ConnectionProfile < ActiveRecord::Base
  attr_accessible :description, :name, :type

  validates :name, :presence => true, :length => {:maximum => 30, :minimum => 3}, :format => { :with => %r{^[0-9a-zA-Z]+$} },
            :uniqueness => true

  #relationships
  has_many :plans
  has_many :probes
  has_many :thresholds
end
