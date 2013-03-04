class Quotient < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :threshold
  attr_accessible :download, :end_timestamp, :expected_days, :schedule_uuid, :start_timestamp, :total_days, :upload
end
