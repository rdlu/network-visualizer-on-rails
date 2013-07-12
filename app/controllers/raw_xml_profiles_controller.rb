class RawXmlProfilesController < ApplicationController
    def new
        authorize! :manage, self
        @profile = Profile.new

        respond_to do |format|
            format.html
        end
    end

    def edit
        authorize! :manage, self
        @profile = Profile.find(params[:id])

        unless @profile.config_method == "raw_xml"
            redirect_to edit_profile_path(@profile)
        end
    end

    def create
        authorize! :manage, self

        @profile = Profile.new(params[:profile])
        @profile.config_method = "raw_xml"

        respond_to do |format|
            if @profile.save
                format.html { redirect_to raw_xml_profile_path(@profile), notice: "Novo perfil criado."}
            else
                format.html { render action: "new" }
            end
        end
    end

    def show
        authorize! :manage, self
        @profile = Profile.find(params[:id])

        unless @profile.config_method == "raw_xml"
            redirect_to profile_path(@profile)
            return
        end

        respond_to do |format|
            format.html
        end
    end

    def update
        authorize! :manage, self
        @profile = Profile.find(params[:id])

        unless @profile.config_method = "raw_xml"
            redirect_to update_profile_path(@profile)
            return
        end

        respond_to do |format|
            if @profile.update_attributes(params[:profile])
                format.html { redirect_to raw_xml_profile_path(@profile), notice: "Atualizado!" }
            else
                format.html { render action: 'edit' }
            end
        end
    end
end
