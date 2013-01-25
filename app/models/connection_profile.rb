class ConnectionProfile < ActiveRecord::Base
  attr_accessible :name_id, :name, :conn_type, :notes

  validates :name_id, :presence => true, :length => {:maximum => 20, :minimum => 2}, :format => { :with => %r{^[0-9a-zA-Z][0-9a-zA-Z\-\_]+[0-9a-zA-Z]$} },
            :uniqueness => true
  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2, :maximum => 30 }

  #relationships
  has_many :plans
  has_many :probes
  has_many :thresholds

  accepts_nested_attributes_for :plans
end
