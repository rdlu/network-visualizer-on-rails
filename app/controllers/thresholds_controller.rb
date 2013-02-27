# coding: utf-8
class ThresholdsController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, self
    @thresholds = Threshold.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @thresholds }
    end
  end

  def show
    authorize! :read, self
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @threshold }
    end
  end

  def new
    authorize! :manage, self
    @threshold = Threshold.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @threshold }
    end
  end

  def edit
    authorize! :manage, self
    @threshold = Threshold.find(params[:id])
  end

  def create
    authorize! :manage, self
    @threshold = Threshold.new(params[:threshold])

    respond_to do |format|
      if @threshold.save
        format.html { redirect_to thresholds_path, notice: "Limiar #{@threshold.name} criado com sucesso." }
        format.json { render json: @threshold, status: :created, location: @threshold }
      else
        format.html { render action: "new" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :manage, self
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      if @threshold.update_attributes(params[:threshold])
        format.html { redirect_to thresholds_path, notice: "Limiar #{@threshold.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :manage, self
  end
end
