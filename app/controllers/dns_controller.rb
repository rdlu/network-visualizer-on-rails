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
    authorize! :manage, self
    @dns = Dns.new(params[:dns])

    respond_to do |format|
      format.html
      format.json { render :json => @dns }
    end
  end

  def create
    authorize! :manage, self
    
    @dns = Dns.new(params[:dns])

    if @dns.save
      respond_to do |format|
        format.html { redirect_to @dns, notice: 'DNS criado' }
      end
    else
      respond_to do |format|
        format.html { render :action => :new, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    authorize! :manage, self
    @dns = Dns.find(params[:id])
  end

  def update
    authorize! :manage, self
    @dns = Dns.find(params[:id])

    respond_to do |format|
      if @dns.update_attributes(params[:dns])
        format.html { redirect_to @dns, notice: 'DNS alterado com sucesso' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    authorize! :manage, self
    @dns = Dns.find(params[:id])
    @dns.destroy

    respond_to do |format|
      format.html { render action: 'index' }
    end
  end
end
