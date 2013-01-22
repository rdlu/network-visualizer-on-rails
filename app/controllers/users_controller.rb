# coding: utf-8
class UsersController < ApplicationController
  before_filter :get_user, :only => [:index,:new,:edit]
  before_filter :accessible_roles, :only => [:new, :edit, :show, :update, :create]
  load_and_authorize_resource :only => [:show,:new,:destroy,:update]
  helper_method :accessible_roles
  skip_load_and_authorize_resource :only => [:edit]

  def new
    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @user }
      format.xml  { render :xml => @user }
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  def edit
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

  def destroy
    @user.destroy

    respond_to do |format|
      format.json { render :json => @user.to_json, :status => 200 }
      format.xml  { head :ok }
      format.html { redirect_to  users_path , :method => :get, :notice =>"Usuário excluído com sucesso!" }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:json, :xml, :html)
  end

  def create
    @user = User.new(params[:user])

    @roles = Role.find(params[:roles])
    @user.roles = @roles

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
    if params[:user][:password].blank?
      [:password,:password_confirmation,:current_password].collect{|p| params[:user].delete(p) }
    else
      @user.errors[:base] << "The password you entered is incorrect" unless @user.valid_password?(params[:user][:current_password])
    end

    respond_to do |format|
      if @user.errors[:base].empty? and @user.update_attributes(params[:user])
        flash[:notice] = "Your account has been updated"
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml  { head :ok }
        format.html { render :action => :edit }
      else
        format.json { render :text => "Could not update user", :status => :unprocessable_entity } #placeholder
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.html { render :action => :edit, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml, :html)
  end

  def index
    authorize! :index, self
    @users = User.paginate(:page       => params[:page],
                           :per_page   => 3,
                           :order      => 'created_at DESC')
  end

  def active
    authorize! :active, self

    @user = User.find(params[:user_id])
    @user.skip_confirmation!
    @user.save!

    respond_to do |format|
      format.json { render :json => @user.to_json, :status => 200 }
      format.xml  { head :ok }
      format.html { redirect_to  users_path , :method => :get, :notice =>"Usuário ativado com sucesso!" }
    end
  end

end