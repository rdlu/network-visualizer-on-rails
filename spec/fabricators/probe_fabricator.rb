# == Schema Information
#
# Table name: probes
#
#  id                    :integer          not null, primary key
#  name                  :string(255)      not null
#  ipaddress             :string(255)      not null
#  description           :text
#  status                :integer          default(0), not null
#  type                  :string(255)      default("android")
#  address               :text
#  pre_address           :text
#  latitude              :float            default(0.0)
#  longitude             :float            default(0.0)
#  plan_id               :integer
#  connection_profile_id :integer
#  created_at            :timestamp(6)     not null
#  updated_at            :timestamp(6)     not null
#  city                  :string(255)      not null
#  state                 :string(255)      not null
#  areacode              :integer
#  anatel                :boolean
#  agent_version         :string(255)
#  pop                   :string(255)
#  bras                  :string(255)
#  osversion             :string(255)
#

Fabricator(:source, from: :probe) do
	name "origem"
	ipaddress "origem"
	status 1
	type "linux"
	city "pindamonhangaba"
	state "sp"
	plan(fabricator: :default, from: :plan)
	connection_profile(fabricator: :default, from: :connection_profile)
end

Fabricator(:destination, from: :probe) do
	name "destino"
	ipaddress "192.168.1.2"
	status 1
	type "android"
	city "conchinchina"
	state "ac"
	plan(fabricator: :default, from: :plan)
	connection_profile(fabricator: :default, from: :connection_profile)
end
