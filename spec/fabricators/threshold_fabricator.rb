# == Schema Information
#
# Table name: thresholds
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  compliance_level      :float            default(0.85), not null
#  compliance_period     :string(255)      default("monthly"), not null
#  compliance_method     :string(255)      default("standard"), not null
#  goal_level            :float            not null
#  goal_period           :string(255)      default("daily"), not null
#  goal_method           :string(255)      default("median"), not null
#  connection_profile_id :integer
#  metric_id             :integer
#  created_at            :timestamp(6)     not null
#  updated_at            :timestamp(6)     not null
#  description           :string(255)
#  base_year             :integer
#

Fabricator(:threshold) do
end
