class Threshold < ActiveRecord::Base
  attr_accessible :compliance_level, :compliance_period, :compliance_method, :goal_level, :goal_method, :goal_period, :name

  belongs_to :connection_profile
  belongs_to :metric
end
