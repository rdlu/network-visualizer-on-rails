class TestProfile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics
end