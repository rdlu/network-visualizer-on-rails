class ConnectionProfile < ActiveRecord::Base
  attr_accessible :description, :name, :type, :notes

  validates :name, :presence => true, :length => {:maximum => 20, :minimum => 3}, :format => { :with => %r{^[0-9a-zA-Z][0-9a-zA-Z\-]+[0-9a-zA-Z]$} },
            :uniqueness => true
  validates :description, :presence => true, :uniqueness => true, :length => { :minimum => 2, :maximum => 30 }

  #relationships
  has_many :plans
  has_many :probes
  has_many :thresholds
end
