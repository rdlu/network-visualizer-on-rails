# coding: utf-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  validate :has_roles?

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :adm_block

  def role?(role)
    !!self.roles.find_by_name(role.to_s)
  end

  def has_roles?
    errors.add :roles, "O usuario precisa de no mínimo um papel." if self.roles.blank?
  end

end