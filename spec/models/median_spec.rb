# encoding: utf-8
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


require 'spec_helper'

describe Median do
	describe "cálculo de medianas" do
		describe "scm4" do
			before do
				@reference_date = DateTime.parse('2012-04-08 12:00:00')
				@from = '2012-04-08 03:00:00'
				@to = '2012-04-09 03:00:00'
				@schedule = Fabricate(:schedule)
				@threshold = Fabricate(:threshold)
			end

			it "deve calcular corretamente" do
				Median.calculate(@schedule, @threshold, @reference_date)

				@medians = Median.
					where(:schedule_id => @schedule.id).
					where(:threshold_id => @threshold.id).
					where('start_timestamp >= ?', @from).
					where('end_timestamp <= ?', @to).order('start_timestamp ASC').all

				@medians.length.must eq(1)
			end
		end
	end
end
