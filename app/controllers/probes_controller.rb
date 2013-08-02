# coding: utf-8
class ProbesController < ApplicationController
  before_filter :authenticate_user!

  #escopos
  has_scope :by_city
  has_scope :by_state, :type => :array_or_string
  has_scope :by_type, :type => :array_or_string
  has_scope :by_pop, :type => :array_or_string
  has_scope :by_bras, :type => :array_or_string
  has_scope :is_anatel
  has_scope :by_modem, :type => :array_or_string
  has_scope :by_tech, :type => :array_or_string

  def index
    authorize! :read, self

    @probes = apply_scopes(Probe).order(:name).all
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
      Probe.add_pop @probe.pop
      Probe.add_modem @probe.modem
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
    @probe = Probe.find(params[:id])

    respond_to do |format|
      if @probe.update_attributes(params[:probe])
        Probe.add_pop @probe.pop
        Probe.add_modem @probe.modem
        format.html { redirect_to probes_path, notice: 'Suas alterações foram salvas com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
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

  def thresholds
    source = Probe.find(params[:source_id])
    destination = Probe.find(params[:id])

    thresholds = destination.thresholds(source)

    respond_to do |format|
      format.json { render :json => thresholds, :status => 200 }
    end
  end

  def load_location
    probe = Probe.all

    respond_to do |format|
      format.json { render :json => probe, :status => 200 }
    end
  end

  def filter_uf
    uf = params[:uf]
    cod_uf =  Array.new
    Probe.states.each do |state|
      uf.each do |uf|
        if state.at(1) == uf
          cod_uf << state.at(1)
        end
      end
    end

    cods = Array.new
    cod_uf.each do |ufs|
      Probe.cod_area.each do |cod_n|
          if ufs == cod_n.at(0).downcase
            cods << cod_n.at(1)
          end
      end
    end

    respond_to do |format|
      format.json { render :json => cods }
    end
  end

  def filter_destination
    uf = params[:uf]
    dest_uf =  Array.new
    Probe.states.each do |state|
      uf.each do |uf|
        if state.at(1) == uf
          dest_uf << state.at(1)
        end
      end
    end

    destinations = Array.new
    dest_uf.each do |ufs|
      Probe.all.each do |p|
        if ufs == p.state.downcase
          destinations << p
        end
      end
    end

    respond_to do |format|
      format.json { render :json => destinations }
    end
  end

  end
