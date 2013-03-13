class UrlProfilesController < ApplicationController
  def new
    authorize! :manage, self
    @profile = Profile.new
    @profile.config_parameters = '{}'

    @sites = Site.all

    respond_to do |format|
      format.html
    end
  end

  def edit
    authorize! :manage, self
    @profile = Profile.find(params[:id])
    @sites = Site.all

    unless @profile.config_method == "url"
      redirect_to edit_profile_path(@profile)
    end
  end

  def create
    authorize! :manage, self

    params[:profile][:sites] ||= []
    @profile = Profile.new(params[:profile])
    @profile.config_method = "url"

    respond_to do |format|
      if @profile.save
        format.html { redirect_to url_profile_path(@profile), notice: "Novo perfil criado."}
      else
        format.html { render action: "new" }
      end
    end
  end

  def show
    authorize! :manage, self
    @profile = Profile.find(params[:id])

    @sites = []
    @profile.sites.each do |site|
      sitetmp = Site.find(site)
      @sites << sitetmp unless sitetmp.nil?
    end

    unless @profile.config_method == "url"
      redirect_to profile_path(@profile)
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @profile }
    end
  end

  def update
    authorize! :manage, self
    params[:profile][:metric_ids] ||= []
    params[:profile][:sites] ||= []
    @profile = Profile.find(params[:id])

    unless @profile.config_method == "url"
      redirect_to update_profile_path(@profile)
      return
    end

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to url_profile_path(@profile), notice: "Updated!" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end
end
