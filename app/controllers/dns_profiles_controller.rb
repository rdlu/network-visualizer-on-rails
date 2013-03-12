class DnsProfilesController < ApplicationController
  def new
    authorize! :manage, self
    @profile = Profile.new
    @profile.config_parameters = '{}'

    @nameservers = Nameserver.all

    respond_to do |format|
      format.html
    end
  end

  def edit
    authorize! :manage, self
    @profile = Profile.find(params[:id])
    @nameservers = Nameserver.all

    unless @profile.config_method == "dns"
      redirect_to edit_profile_path(@profile)
    end
  end

  def create
    authorize! :manage, self

    params[:profile][:nameservers] ||= []
    @profile = Profile.new(params[:profile])
    @profile.config_method = "dns"

    respond_to do |format|
      if @profile.save
        format.html { redirect_to dns_profile_path(@profile), notice: "Novo perfil criado."}
      else
        format.html { render action: "new" }
      end
    end
  end

  def show
    authorize! :manage, self
    @profile = Profile.find(params[:id])

    @nameservers = []
    @profile.nameservers.each do |ns|
      nstmp = Nameserver.find(ns)
      @nameservers << nstmp unless nstmp.nil?
    end

    respond_to do |format|
      unless @profile.config_method == "dns"
        redirect_to profile_path(@profile)
      else
        format.html
        format.json { render json: @profile }
      end
    end
  end

  def update
    authorize! :manage, self
    params[:profile][:metric_ids] ||= []
    @profile = Profile.find(params[:id])

    respond_to do |format|
      unless @profile.config_method == "dns"
        redirect_to update_profile_path(@profile)
      else
        if @profile.update_attributes(params[:profile])
          format.html { redirect_to dns_profile_path(@profile), notice: 'Updated!' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end 
      end
    end
  end
end
