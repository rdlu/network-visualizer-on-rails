class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :roles

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def role?(role)
    !!self.roles.find_by_name(role.to_s)
  end

  def active_for_authentication?
    super && !!self.adm_block
  end

  def inactive_message
     :locked
  end

end