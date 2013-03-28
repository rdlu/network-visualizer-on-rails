# coding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user, :only => [:index,:new,:edit]
  before_filter :accessible_roles, :only => [:new, :edit, :show, :update, :create]
  load_and_authorize_resource :only => [:show,:new,:destroy,:update]
  helper_method :accessible_roles
  skip_load_and_authorize_resource :only => [:edit]

  #escopos
  has_scope :by_status
  has_scope :inactive


  def new
    authorize! :manage, self
    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end
  end

  def show
    authorize! :read, self
    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  def edit
    authorize! :manage, self
    @user = User.find(params[:id])
    if @user != @current_user
      authorize! :edit, @user
    end
    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  def update_password
    authorize! :manage, self
    @user = User.find(current_user.id)
    if @user.update_with_password(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  def destroy
    authorize! :manage, self
    @user.destroy

    if @user != @current_user
    respond_to do |format|
      format.json { render :json => @user.to_json, :status => 200 }
      format.xml  { head :ok }
      format.html { redirect_to  users_path ,:method => :get, :notice => "Conta excluida com sucesso!" }
      end
    else
      respond_to do |format|
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html { redirect_to  users_sign_in_path ,:method => :get }
      end
    end

    rescue ActiveRecord::RecordNotFound
      respond_to_not_found(:json, :xml, :html)
  end

  def create
    authorize! :manage, self
    @user = User.new(params[:user])

    params_roles = (params.has_key? :roles) ? params[:roles] : nil
    if params.has_key? :roles
      @roles = Role.find(params_roles)
      @user.roles = @roles
      @user.adm_block = true
    else

    end

    if @user.save
      respond_to do |format|
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html { redirect_to welcome_index_path, :notice =>"Cadastro feito com sucesso. Um e-mail foi enviado para #{@user.email}" }
      end
    else
      respond_to do |format|
        format.json { render :text => "Usuário não pode ser criado.", :status => :unprocessable_entity } # placeholder
        format.xml  { head :ok }
        format.html { render :action => :new, :status => :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :manage, self
    @user = User.find(params[:id])

    if @user != @current_user
      go_to = users_path
      if params[:roles].blank?
         #se nenhuma opcao foi marcada o papel continua o mesmo
         @roles = Role.find(@user.roles.map{|i| i.id})
         @user.roles = @roles
      else
         @roles = Role.find(params[:roles])
         @user.roles = @roles
      end
    else
      # TODO: verificar isto
      if params[:user][:password].blank
        flash[:notice] = "Senha não foi alterada"
      end
      go_to = welcome_index_path
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        #flash[:notice] = "Your account has been updated"
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html {  redirect_to go_to, :notice =>"Conta alterada com sucesso." }
      else
        format.json { render :text => "Could not update user", :status => :unprocessable_entity } #placeholder
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.html { render :action => :edit, :status => :unprocessable_entity }
      end
    end

  end

  def index
    authorize! :read, self
    @users = User.paginate(:page       => params[:page],
                           :per_page   => 15,
                           :order      => 'created_at DESC')
  end

  def active
    authorize! :read, self

    @user = User.find(params[:user_id])
    if @user.confirmation_token == nil
      @user.skip_confirmation!
      @user.confirmed_at = DateTime.current
      @user.confirmation_token = Devise.token_authentication_key
      @user.adm_block = 1
    else
      @user.confirmed_at= nil
      @user.confirmation_token= nil
      @user.adm_block = 0
    end

    @user.save!

    respond_to do |format|
      format.json { render :json => @user.to_json, :status => 200 }
      format.xml  { head :ok }
      format.html { redirect_to  users_path , :method => :get, :notice => "Alteração feita com sucesso!" }
    end
  end

end
