class Results < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :metric
  attr_accessible :dsavg, :dsmax, :dsmin, :schedule_uuid, :sdavg, :sdmax, :sdmin, :timestamp, :uuid, :metric_name
end
