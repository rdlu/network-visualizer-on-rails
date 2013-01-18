class Plan < ActiveRecord::Base
  attr_accessible :description, :name, :throughput

  validates :name, :presence => true, :length => {:maximum => 255, :minimum => 3},
            :uniqueness => true

  validates :throughput, :presence => true, :numericality => { :only_integer => true }

  #relationships
  has_many :probes
  belongs_to :connection_profile
end