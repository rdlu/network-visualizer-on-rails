# coding: utf-8
# == Schema Information
#
# Table name: connection_profiles
#
#  id         :integer          not null, primary key
#  name_id    :string(255)
#  name       :string(255)
#  conn_type  :string(255)
#  created_at :timestamp(6)     not null
#  updated_at :timestamp(6)     not null
#  notes      :text
#


Fabricator(:default, from: :connection_profile) do
	name_id "default"
	name "Perfil Padrão"
	conn_type "mobile"
end
