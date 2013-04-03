# coding: utf-8

Fabricator(:default, from: :plan) do
	name "default"
	throughput_down 1000
	throughput_up 1000
	connection_profile(fabricator: :default, from: :connection_profile)
end
