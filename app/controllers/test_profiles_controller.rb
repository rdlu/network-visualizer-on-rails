class TestProfilesController < ApplicationController
  # GET /test_profiles
  # GET /test_profiles.json
  def index
    @test_profiles = TestProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @test_profiles }
    end
  end

  # GET /test_profiles/1
  # GET /test_profiles/1.json
  def show
    @test_profile = TestProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_profile }
    end
  end

  # GET /test_profiles/new
  # GET /test_profiles/new.json
  def new
    @test_profile = TestProfile.new
    @test_profile.config_parameters = "{}"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_profile }
    end
  end

  # GET /test_profiles/1/edit
  def edit
    @test_profile = TestProfile.find(params[:id])
  end

  # POST /test_profiles
  # POST /test_profiles.json
  def create
    @test_profile = TestProfile.new(params[:test_profile])

    respond_to do |format|
      if @test_profile.save
        format.html { redirect_to @test_profile, notice: 'Test profile was successfully created.' }
        format.json { render json: @test_profile, status: :created, location: @test_profile }
      else
        format.html { render action: "new" }
        format.json { render json: @test_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_profiles/1
  # PUT /test_profiles/1.json
  def update
    @test_profile = TestProfile.find(params[:id])

    respond_to do |format|
      if @test_profile.update_attributes(params[:test_profile])
        format.html { redirect_to @test_profile, notice: 'Test profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_profiles/1
  # DELETE /test_profiles/1.json
  def destroy
    @test_profile = TestProfile.find(params[:id])
    @test_profile.destroy

    respond_to do |format|
      format.html { redirect_to test_profiles_url }
      format.json { head :no_content }
    end
  end
end
