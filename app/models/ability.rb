class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.role? :admin
      can :manage, :all
    elsif  user.role? :normal
     can :read, :all
     can :manage, Probe
     can :destroy, user
     can :update, user
    end
  end

end