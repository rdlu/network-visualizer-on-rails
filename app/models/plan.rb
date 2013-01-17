class Plan < ActiveRecord::Base
  attr_accessible :description, :name, :throughput

  #relationships
  has_many :probes
  belongs_to :connection_profile
end
