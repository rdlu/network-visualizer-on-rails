require 'spec_helper'

describe Nameserver do
	before do
		@ns1 = create(:nameserver)
	end

	describe "attributes" do
		it "should save attributes on the db" do
			@ns1.address.should eq attributes_for(:nameserver)[:address]
		end
	end
end
