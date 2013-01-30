# coding: utf-8
class ThresholdsController < ApplicationController

  def index
    @thresholds = Threshold.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @thresholds }
    end
  end

  def show
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @threshold }
    end
  end

  def new
    @threshold = Threshold.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @threshold }
    end
  end

  def edit
    @threshold = Threshold.find(params[:id])
  end

  def create
    @threshold = Threshold.new(params[:schedule])

    respond_to do |format|
      if @threshold.save
        format.html { redirect_to @threshold, notice: "Limiar #{@threshold.name} criado com sucesso." }
        format.json { render json: @threshold, status: :created, location: @threshold }
      else
        format.html { render action: "new" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      if @threshold.update_attributes(params[:schedule])
        format.html { redirect_to @threshold, notice: "Limiar #{@threshold.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end
end
