class WelcomeController < ApplicationController

  def index
    authorize! :index, WelcomeController
    render 'index.html.erb'
  end

end
