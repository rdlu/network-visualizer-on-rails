class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.role? :admin
      can :manage, :all
    elsif  user.role? :normal
      can :read, :all
      can :manage, Probe
      can :manage, Schedule
      can :manage, Profile
      can :manage, Reports
      can :destroy, user
      can :update, user
    elsif user.role? :visualizador
      can :read, :all
      can :manage, user
    end
  end

end
