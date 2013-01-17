class Threshold < ActiveRecord::Base
  attr_accessible :compliance_level, :compliance_period, :compliance_method, :goal_level, :goal_method, :goal_period, :name
end
