# coding: utf-8
class RegistrationController < ApplicationController


  def new
    authorize! :new, self
    @user = User.new
    respond_to do |format|
       format.html
    end
  end

  def create
    authorize! :create, self
    @user = User.new(params[:user])

    @roles = Role.find(params[:roles])
    @user.roles = @roles

    if @user.save
      respond_to do |format|
        format.html {
          redirect_to welcome_index_path, :notice =>"Cadastro feito com sucesso. Um e-mail foi enviado para #{@user.email}" }
      end
    else
      respond_to do |format|
         format.html { render :action => :new, :status => :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, self

    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      #set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      #sign_in @user, :bypass => true
      redirect_to registration_index_path, :notice =>"Alteração feita com sucesso"
    else
      render "registration/edit.html.erb"
    end

  end

  def index
     authorize! :index, self
     @users = User.paginate(:page       => params[:page],
                          :per_page   => 3,
                          :order      => 'created_at DESC')
  end

  def delete
    authorize! :delete, self
    render "registration/delete.html.erb"
  end

  def edit
    authorize! :edit, self
    @user = params[:user]

    render "registration/edit.html.erb"
  end

  def active
    authorize! :active, self
    render "registration/active.html.erb"
  end

end
