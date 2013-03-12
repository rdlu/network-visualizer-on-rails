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
  end

  def create
    authorize! :manage, self

    @profile = Profile.new(params[:profile])
    @profile.config_method = "dns"

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: "Novo perfil criado."}
      else
        format.html { render action: "new_dns" }
      end
    end
  end

  def show

  end

  def update

  end
end
