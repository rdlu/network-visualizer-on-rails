# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :timestamp(6)     not null
#  updated_at  :timestamp(6)     not null
#  description :string(255)
#

class Role < ActiveRecord::Base
  attr_accessible :name, :description

  has_and_belongs_to_many :users
end
