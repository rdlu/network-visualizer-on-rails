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

end
