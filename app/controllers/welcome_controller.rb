class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:login]

  def index
    authorize! :index, self
    render 'index.html.erb'
  end

  def login
    if get_user.nil?
      redirect_to :controller => "users", :action => "sign_in"
    else
      redirect_to :controller => "welcome", :action => "index"
    end
  end

  def route_reload
    reload_routes
    render :layout => false, :html => 'OK'
  end

end
