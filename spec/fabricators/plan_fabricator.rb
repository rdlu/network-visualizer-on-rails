# coding: utf-8
# == Schema Information
#
# Table name: plans
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  description           :text
#  throughput_down       :integer
#  connection_profile_id :integer
#  created_at            :timestamp(6)     not null
#  updated_at            :timestamp(6)     not null
#  throughput_up         :integer
#


Fabricator(:default, from: :plan) do
	name "default"
	throughput_down 1000
	throughput_up 1000
	connection_profile(fabricator: :default, from: :connection_profile)
end
