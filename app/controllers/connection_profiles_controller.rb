class ConnectionProfilesController < ApplicationController
  # GET /connection_profiles
  # GET /connection_profiles.json
  def index
    @connection_profiles = ConnectionProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @connection_profiles }
    end
  end

  # GET /connection_profiles/1
  # GET /connection_profiles/1.json
  def show
    @connection_profile = ConnectionProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @connection_profile }
    end
  end

  # GET /connection_profiles/new
  # GET /connection_profiles/new.json
  def new
    @connection_profile = ConnectionProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @connection_profile }
    end
  end

  # GET /connection_profiles/1/edit
  def edit
    @connection_profile = ConnectionProfile.find(params[:id])
  end

  # POST /connection_profiles
  # POST /connection_profiles.json
  def create
    @connection_profile = ConnectionProfile.new(params[:connection_profile])

    respond_to do |format|
      if @connection_profile.save
        format.html { redirect_to @connection_profile, notice: 'Connection profile was successfully created.' }
        format.json { render json: @connection_profile, status: :created, location: @connection_profile }
      else
        format.html { render action: "new" }
        format.json { render json: @connection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /connection_profiles/1
  # PUT /connection_profiles/1.json
  def update
    @connection_profile = ConnectionProfile.find(params[:id])

    respond_to do |format|
      if @connection_profile.update_attributes(params[:connection_profile])
        format.html { redirect_to @connection_profile, notice: 'Connection profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @connection_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /connection_profiles/1
  # DELETE /connection_profiles/1.json
  def destroy
    @connection_profile = ConnectionProfile.find(params[:id])
    @connection_profile.destroy

    respond_to do |format|
      format.html { redirect_to connection_profiles_url }
      format.json { head :no_content }
    end
  end
end
