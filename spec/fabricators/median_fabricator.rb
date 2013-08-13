# == Schema Information
#
# Table name: medians
#
#  id              :integer          not null, primary key
#  schedule_id     :integer
#  threshold_id    :integer
#  schedule_uuid   :string
#  start_timestamp :timestamp(6)
#  end_timestamp   :timestamp(6)
#  expected_points :integer
#  total_points    :integer
#  dsavg           :float
#  sdavg           :float
#  created_at      :timestamp(6)     not null
#  updated_at      :timestamp(6)     not null
#  type            :string(255)
#

Fabricator(:median) do
end
