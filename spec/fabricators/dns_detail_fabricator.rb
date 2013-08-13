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

Fabricator(:dns_detail) do
  efic                  1.5
  average               1.5
  timeout_errors        1
  server_failure_errors 1
  uuid                  "MyString"
end
