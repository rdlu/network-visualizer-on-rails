class TestProfile < ActiveRecord::Base
  attr_accessible :config_method, :config_parameters, :name, :connection_profile_id, :metric_ids

  #relationships
  belongs_to :connection_profile
  has_and_belongs_to_many :metrics

  accepts_nested_attributes_for :metrics
end