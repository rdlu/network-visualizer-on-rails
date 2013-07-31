class ProcessController < ApplicationController

  def index
=begin
    authorize! :read, self
    @process = Process.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @process }
    end
=end
  end

  def new

  end

  def show

  end

  def edit

  end

  def remove

  end

  def update

  end


end
