class Evaluation < ActiveRecord::Base
  attr_accessible :schedule_id, :test_profile_id

  belongs_to :schedule
  belongs_to :profile
end
