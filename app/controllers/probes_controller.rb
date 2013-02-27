# coding: utf-8
class ProbesController < ApplicationController
  before_filter :authenticate_user!
  helper_method :states
  helper_method :types

  #escopos
  has_scope :by_city
  has_scope :by_state
  has_scope :by_type

  def index
    authorize! :read, self

    @probes = apply_scopes(Probe).all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @probes }
    end
  end

  def show
    authorize! :read, self
    @probe = Probe.find(params[:id])
  end

  def new
    authorize! :manage, self
    @probe = Probe.new(params[:probe])

    begin
      @selected_plan = ConnectionProfile.find(params[:probe][:connection_profile_id]).plans
    rescue
      @selected_plan = ConnectionProfile.all.first.plans
    end

    respond_to do |format|
      format.json { render :json => @probe }
      format.xml  { render :xml => @probe }
      format.html
    end
  end

  def edit
    authorize! :manage, self
    @probe = Probe.find(params[:id])

    begin
      @selected_plan = ConnectionProfile.find(params[:probe][:connection_profile_id]).plans
    rescue
      @selected_plan = ConnectionProfile.all.first.plans
    end
  end

  def create
    authorize! :manage, self
    @probe = Probe.new(params[:probe])

    @connection_profile = ConnectionProfile.find(params[:probe][:connection_profile_id])
    @probe.connection_profile = @connection_profile

    @plan = Plan.find(params[:probe][:plan_id])
    @probe.plan = @plan

    begin
      @selected_plan = ConnectionProfile.find(params[:probe][:connection_profile_id]).plans
    rescue
      @selected_plan = ConnectionProfile.all.first.plans
    end

    if @probe.save
      respond_to do |format|
        format.json { render :json => @probe.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html
      end
    else
      respond_to do |format|
        format.json { render :text => "Sonda não pode ser criado.", :status => :unprocessable_entity } # placeholder
        format.xml  { head :ok }
        format.html { render :action => :new, :status => :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :manage, self
  end

  def destroy
    authorize! :manage, self
  end

  def sources
    probe = Probe.find(params[:id])

    respond_to do |format|
      format.json { render :json => probe.sources, :status => 200 }
    end
  end

  def destinations
    probe = Probe.find(params[:id])

    respond_to do |format|
      format.json { render :json => probe.destinations, :status => 200 }
    end
  end

  def metrics
    source = Probe.find(params[:source_id])
    destination = Probe.find(params[:id])

    metrics = destination.metrics(source)

    respond_to do |format|
      format.json { render :json => metrics, :status => 200 }
    end
  end

  def load_location
    probe = Probe.all

    respond_to do |format|
      format.json { render :json => probe, :status => 200 }
    end
  end

  protected

  def types
    [%w(Android android),
     %w(Linux linux)]
  end

  def states
    [["Rio de Janeiro","rj"],
    ["Rio Grande do Sul","rs"],
    ["São Paulo","sp"]]
  end



end
