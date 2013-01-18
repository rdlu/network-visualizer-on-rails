class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  check_authorization :unless => :devise_controller?


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Acesso Negado! #{exception.message}"
    redirect_to root_url
  end

end