# == Schema Information
#
# Table name: evaluations
#
#  id          :integer          not null, primary key
#  schedule_id :integer
#  profile_id  :integer
#  created_at  :timestamp(6)     not null
#  updated_at  :timestamp(6)     not null
#

class Evaluation < ActiveRecord::Base
  attr_accessible :schedule_id, :test_profile_id

  belongs_to :schedule
  belongs_to :profile
end
