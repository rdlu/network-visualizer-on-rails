class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.role? :admin
      can :manage, :all
      #can :edit, edit_user_registration_path
      #can :new, User
    elsif  user.role? :normal
      #can :minha_action, Algumacoisa
      can :manage, :all
      cannot :new, RegistrationController
      #cannot :index, RegistrationController
    else
      can :manage, :all
      #can :read, SessionsController
      #cannot :index, WelcomeController
      #can :new, [Devise,User]
    end
  end

end