Fabricator(:schedule) do |s|
	start '2012-01-01 00:00:00'
	s.end '2012-31-12 23:59:59'
	polling 10
	status "active"
	uuid "bf0f4c96-085e-4129-871b-fe8a1e85bb73"

	source(fabricator: :source, from: :probe )
	destination(fabricator: :destination, from: :probe )
end
