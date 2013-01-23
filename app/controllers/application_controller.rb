class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_blocked
  helper_method :get_user

  protected

  def accessible_roles
    @accessible_roles = Role.accessible_by(current_ability,:read)
  end

  def get_user
    @current_user = current_user
  end

  def check_blocked
    if @current_user.adm_block != 0
      false
    else
      true
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Acesso Negado! #{exception.message}"
    redirect_to "/422.html"
  end

end