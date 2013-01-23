class Plan < ActiveRecord::Base
  attr_accessible :description, :name, :throughputDown, :throughputUp

  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3}
  validates_uniqueness_of :name
  validates :throughputDown, :presence => true, :numericality => { :only_integer => true }
  validates :throughputUp, :presence => true, :numericality => { :only_integer => true }

  #relationships
  has_many :probes
  belongs_to :connection_profile
end