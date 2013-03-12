class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  # GET /profiles
  # GET /profiles.json
  def index
    authorize! :read, self
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    authorize! :read, self
    @profile = Profile.find(params[:id])

    if @profile.config_method == "dns"
      redirect_to dns_profile_path(@profile)
      return
    elsif @profile.config_method == "url"
      redirect_to url_profile_path(@profile)
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    authorize! :manage, self
    @profile = Profile.new
    @profile.config_parameters = '{}'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    authorize! :manage, self
    @profile = Profile.find(params[:id])
    if @profile.config_method == "dns"
      redirect_to edit_dns_profile_path(@profile)
    elsif @profile.config_method == "url"
      redirect_to edit_url_profile_path(@profile)
    end
  end

  # POST /profiles
  # POST /profiles.json
  def create
    authorize! :manage, self
    params[:profile][:metric_ids] ||= []
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Evaluation profile was successfully created.' }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    authorize! :manage, self
    params[:profile][:metric_ids] ||= []
    @profile = Profile.find(params[:id])

    if @profile.config_method == "dns"
      redirect_to update_dns_profile_path(@profile)
      return
    elsif @profile.config_method == "url"
      redirect_to update_url_profile_path(@profile)
      return
    end

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to @profile, notice: 'Evaluation profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    authorize! :manage, self
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to test_profiles_url }
      format.json { head :no_content }
    end
  end
end
