require 'spec_helper'

describe Nameserver do
	before do
		@ns1 = create(:nameserver)
	end

	describe "attributes" do
		it "should save attributes on the db" do
			@ns1.address.should eq attributes_for(:nameserver)[:address]
			@ns1.internal.should eq attributes_for(:nameserver)[:internal]
			@ns1.name.should eq attributes_for(:nameserver)[:name]
			@ns1.primary.should eq attributes_for(:nameserver)[:primary]
			@ns1.vip.should eq attributes_for(:nameserver)[:vip]
		end

		it "should print the correct pretty name" do
			@ns1.pretty_name.should eq "#{attributes_for(:nameserver)[:name]} (#{attributes_for(:nameserver)[:address]})"
		end
	end
end
