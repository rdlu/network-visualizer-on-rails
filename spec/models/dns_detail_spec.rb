# == Schema Information
#
# Table name: dns_details
#
#  id                    :integer          not null, primary key
#  efic                  :float
#  average               :float
#  timeout_errors        :integer
#  server_failure_errors :integer
#  uuid                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe DnsDetail do
  pending "add some examples to (or delete) #{__FILE__}"
end
