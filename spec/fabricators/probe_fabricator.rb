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
