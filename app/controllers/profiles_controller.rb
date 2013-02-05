class ProfilesController < ApplicationController
  # GET /Profiles
  # GET /Profiles.json
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /Profiles/1
  # GET /Profiles/1.json
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /Profiles/new
  # GET /Profiles/new.json
  def new
    @profile = Profile.new
    @profile.config_parameters = '{}'

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /Profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
  end

  # POST /Profiles
  # POST /Profiles.json
  def create
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

  # PUT /Profiles/1
  # PUT /Profiles/1.json
  def update
    params[:profile][:metric_ids] ||= []
    @profile = Profile.find(params[:id])

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

  # DELETE /Profiles/1
  # DELETE /Profiles/1.json
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to test_profiles_url }
      format.json { head :no_content }
    end
  end
end
