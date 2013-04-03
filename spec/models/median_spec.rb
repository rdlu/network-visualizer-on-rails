# encoding: utf-8

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
