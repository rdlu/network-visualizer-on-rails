# coding: utf-8
class PlansController < ApplicationController
  before_filter :authenticate_user!
  before_filter :accessible_connections, :only => [:new, :edit, :show, :update, :create]
  helper_method :accessible_connections
  has_scope :by_connection_profile

  # GET /plans
  # GET /plans.json
  def index
    authorize! :read, self

    if params.has_key? :connection_profile_id
      @conn_profile = ConnectionProfile.find(params[:connection_profile_id])
      @plans = @conn_profile.plans
    elsif request.format == 'html'
      @plans = Plan.paginate(:page => params[:page],
                             :per_page => 15,
                             :order => 'name')
    else
      @plans = Plan.order(:name).all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plans }
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    authorize! :read, self
    @plan = Plan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @plan }
    end
  end

  # GET /plans/new
  # GET /plans/new.json
  def new
    authorize! :manage, self
    @plan = Plan.new

    respond_to do |format|
      if !accessible_connections.present?
        format.html { redirect_to plans_path, notice: 'Você deve criar um Perfil de conexão antes de cadastrar um novo plano.' }
        format.json { head :no_content }
      else
        format.html # new.html.erb
        format.json { render json: @plan }
      end
    end
  end

  # GET /plans/1/edit
  def edit
    authorize! :manage, self
    @plan = Plan.find(params[:id])
  end

  # POST /plans
  # POST /plans.json
  def create
    authorize! :manage, self
    @plan = Plan.new(params[:plan])

    @connection_profile = ConnectionProfile.find(params[:plan][:connection_profile_id])
    @plan.connection_profile = @connection_profile

    respond_to do |format|
      if @plan.save
        format.html { redirect_to plans_path, notice: 'Plano criado com sucesso.' }
        format.json { render json: @plan, status: :created, location: @plan }
      else
        format.html { render action: "new" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /plans/1
  # PUT /plans/1.json
  def update
    authorize! :manage, self
    @plan = Plan.find(params[:id])

    respond_to do |format|
      if @plan.update_attributes(params[:plan])
        format.html { redirect_to plans_path, notice: 'Suas alterações foram salvas com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    authorize! :manage, self
    @plan = Plan.find(params[:id])
    @plan.destroy

    respond_to do |format|
      format.html { redirect_to plans_url }
      format.json { head :no_content }
    end
  end
end
