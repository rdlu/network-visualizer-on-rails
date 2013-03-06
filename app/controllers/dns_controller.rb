class DnsController < ApplicationController
  before_filter :authenticate_user!
  def index
    authorize! :read, self

    @dns_list = Dns.all

    respond_to do |format|
      format.html
      format.json { render json: @dns_list }
    end
  end

  def show
    authorize! :read, self
    @dns = Dns.find(params[:id])
  end

  def new
  end

  def delete
  end
end
