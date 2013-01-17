class ConnectionProfile < ActiveRecord::Base
  attr_accessible :description, :name, :type

  #relationships
  has_many :plans
  has_many :probes
  has_many :thresholds
end
