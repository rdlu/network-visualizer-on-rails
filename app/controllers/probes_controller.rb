# coding: utf-8
class ProbesController < ApplicationController
  helper_method :states
  helper_method :types

  #escopos
  has_scope :by_city
  has_scope :by_state
  has_scope :by_type

  def index
    authorize! :index, self

    @probes = apply_scopes(Probe).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @probes }
    end
  end

  def show
  end

  def new
    @probe = Probe.new(params[:probe])
    respond_to do |format|
      format.json { render :json => @probe }
      format.xml  { render :xml => @probe }
      format.html
    end
  end

  def edit
  end

  def create
    @probe = Probe.new(params[:probe])

    @connection_profile = ConnectionProfile.find(params[:connection_profile])
    @probe.connection_profile = @connection_profile

    @plan = Plan.find(params[:plan])
    @probe.plan = @plan

    if @probe.save
      respond_to do |format|
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html { redirect_to welcome_index_path, :notice =>"Cadastro feito com sucesso. Um e-mail foi enviado para #{@user.email}" }
      end
    else
      respond_to do |format|
        format.json { render :text => "Usuário não pode ser criado.", :status => :unprocessable_entity } # placeholder
        format.xml  { head :ok }
        format.html { render :action => :new, :status => :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
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
