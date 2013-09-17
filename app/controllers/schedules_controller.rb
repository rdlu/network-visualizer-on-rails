# coding: utf-8
class SchedulesController < ApplicationController
  # GET /schedules
  # GET /schedules.json
  def index
    authorize! :read, self
    @schedules = Schedule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schedules }
    end
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
    authorize! :read, self
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/new
  # GET /schedules/new.json
  def new
    authorize! :manage, self
    @schedule = Schedule.new
    @connection_profile = ConnectionProfile.find(1)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    authorize! :manage, self
    @schedule = Schedule.find(params[:id])
  end

  # POST /schedules
  # POST /schedules.json
  def create
    authorize! :manage, self
    @schedule = Schedule.new(params[:schedule])

    respond_to do |format|
      if @schedule.save
        Yell.new(:gelf, :facility=>'netmetric').info 'Nova agenda configurada com sucesso.',
          '_schedule_id' => @schedule.id, '_destination_name' => @schedule.destination.name,
          '_source_name' => @schedule.source.name
        format.html { redirect_to @schedule, notice: 'Agenda programada com sucesso.' }
        format.json { render json: @schedule, status: :created, location: @schedule }
      else
        format.html { render action: 'new' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.json
  def update
    authorize! :manage, self
    @schedule = Schedule.find(params[:id])

    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to @schedule, notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    authorize! :manage, self
    @schedule = Schedule.find(params[:id])
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to schedules_url }
      format.json { head :no_content }
    end
  end

  def unused_profiles_form
    schedules = Schedule.where(:destination_id => params[:destination_id]).where(:source_id => params[:source_id]).all
    @connection_profile = Probe.find(params[:destination_id]).connection_profile
    @used_profiles = []
    schedules.each do |schedule|
      @used_profiles += schedule.profiles
    end
    @used_profiles = @used_profiles.uniq
    #WIRLAU - alterado provisoriamente para pegar todos os profiles
 #  @profiles = Profile.where(connection_profile_id: [@connection_profile.id,nil,""]).all
    @profiles = Profile.all;
    
    @unused_profiles = @profiles - @used_profiles

    render :layout => false
  end

  # Windows Schedules
  def win
    respond_to do |format|
      format.xml
    end
  end

  # Android / Linux Schedules
  def private_schedule
    ipaddress = params[:ipaddress]
    @probe = Probe.where(ipaddress: ipaddress).first

    @schedules = Schedule.where(destination_id: @probe.id).all

    respond_to do |format|
      format.xml
    end
  end

  # Android / Linux Schedules
  def private_agt_index
      ipaddress = params[:ipaddress]
      @probe = Probe.where(ipaddress: ipaddress).first;
      if @probe.nil?
	@probe_id = -1
      else
        @probe_id = @probe.id
      end
#     @schedules = Schedule.where(destination_id: @probe.id).all

      respond_to do |format|
          format.xml
      end
  end

end
