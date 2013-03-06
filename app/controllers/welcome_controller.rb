class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:login]
  include ApplicationHelper

  def index
    authorize! :index, self
    render 'index.html.erb'
  end

  def login
    if get_user.nil?
      redirect_to :controller => 'users', :action => 'sign_in'
    else
      redirect_to :controller => 'welcome', :action => 'index'
    end
  end

  def route_reload
    reload_routes
    render :layout => false, :html => 'OK'
  end

  def status
    respond_to do |format|
      format.json { render json: schedule_for_probes(params[:source], params[:destination])}
    end
  end

  def stats
    respond_to do |format|
      format.json { render json: schedule_for_all_probes }
    end
  end

end
