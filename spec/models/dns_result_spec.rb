# == Schema Information
#
# Table name: dns_results
#
#  id         :integer          not null, primary key
#  server     :string(255)
#  url        :string(255)
#  delay      :integer
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :string(255)
#

require 'spec_helper'

describe DnsResult do
  pending "add some examples to (or delete) #{__FILE__}"
end
