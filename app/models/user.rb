# coding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :timestamp(6)
#  remember_created_at    :timestamp(6)
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :timestamp(6)
#  last_sign_in_at        :timestamp(6)
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :timestamp(6)
#  confirmation_sent_at   :timestamp(6)
#  unconfirmed_email      :string(255)
#  created_at             :timestamp(6)     not null
#  updated_at             :timestamp(6)     not null
#  adm_block              :boolean          default(TRUE)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles
  validate :has_roles?
#  validates :password, :presence => {:message => "não pode ficar em branco"}
#  validates :password_confirmation, :presence => {:message => "não pode ficar em branco"}

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :adm_block

  def role?(role)
    !!self.roles.find_by_name(role.to_s)
  end

  def has_roles?
    errors.add :roles, "O usuário precisa de no mínimo um papel." if self.roles.blank?
  end

  def active_for_authentication?
    super && !self.adm_block
  end

  def inactive_message
   if super && self.adm_block
     :unconfirmed
   else
     :locked
   end
  end


end
