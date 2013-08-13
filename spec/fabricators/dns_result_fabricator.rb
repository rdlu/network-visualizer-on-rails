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

Fabricator(:dns_result) do
  server "MyString"
  url    "MyString"
  delay  1
  uuid   "MyString"
end
