class NameserversController < ApplicationController
  before_filter :authenticate_user!
  # GET /nameservers
  # GET /nameservers.json
  def index
    authorize! :read, self
    @nameservers = Nameserver.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nameservers }
    end
  end

  # GET /nameservers/1
  # GET /nameservers/1.json
  def show
    authorize! :read, self
    @nameserver = Nameserver.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nameserver }
    end
  end

  # GET /nameservers/new
  # GET /nameservers/new.json
  def new
    authorize! :manage, self
    @nameserver = Nameserver.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nameserver }
    end
  end

  # GET /nameservers/1/edit
  def edit
    authorize! :manage, self
    @nameserver = Nameserver.find(params[:id])
  end

  # POST /nameservers
  # POST /nameservers.json
  def create
    authorize! :manage, self
    @nameserver = Nameserver.new(params[:nameserver])

    respond_to do |format|
      if @nameserver.save
        format.html { redirect_to @nameserver, notice: 'Nameserver foi criado com sucesso.' }
        format.json { render json: @nameserver, status: :created, location: @nameserver }
      else
        format.html { render action: "new" }
        format.json { render json: @nameserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nameservers/1
  # PUT /nameservers/1.json
  def update
    authorize! :manage, self
    @nameserver = Nameserver.find(params[:id])

    respond_to do |format|
      if @nameserver.update_attributes(params[:nameserver])
        format.html { redirect_to @nameserver, notice: 'Nameserver foi atualizado com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nameserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nameservers/1
  # DELETE /nameservers/1.json
  def destroy
    authorize! :manage, self
    @nameserver = Nameserver.find(params[:id])
    @nameserver.destroy

    respond_to do |format|
      format.html { redirect_to nameservers_url }
      format.json { head :no_content }
    end
  end
end
