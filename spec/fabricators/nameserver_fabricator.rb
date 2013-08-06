# == Schema Information
#
# Table name: nameservers
#
#  id         :integer          not null, primary key
#  address    :string(255)
#  name       :string(255)
#  primary    :boolean
#  vip        :boolean
#  internal   :boolean
#  created_at :timestamp(6)     not null
#  updated_at :timestamp(6)     not null
#

Fabricator(:nameserver) do
end
