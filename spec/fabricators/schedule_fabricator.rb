# == Schema Information
#
# Table name: schedules
#
#  id             :integer          not null, primary key
#  start          :timestamp(6)
#  end            :timestamp(6)
#  polling        :integer
#  status         :string(255)
#  created_at     :timestamp(6)     not null
#  updated_at     :timestamp(6)     not null
#  uuid           :string
#  destination_id :integer
#  source_id      :integer
#

Fabricator(:schedule) do |s|
	start '2012-01-01 00:00:00'
	s.end '2012-31-12 23:59:59'
	polling 10
	status "active"
	uuid "bf0f4c96-085e-4129-871b-fe8a1e85bb73"

	source(fabricator: :source, from: :probe )
	destination(fabricator: :destination, from: :probe )
end
