class ProfileController < ApplicationController
  def new
  end

  def edit
  end

  def delete
    render :partial=> "delete.html.erb"
  end

end
