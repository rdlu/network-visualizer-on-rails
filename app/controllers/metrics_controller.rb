# coding: utf-8
class MetricsController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, self
    @metrics = Metric.order('"order" ASC').all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metrics }
    end
  end

  def new
    authorize! :manage, self
    @metric = Metric.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metric }
    end
  end

  def edit
    authorize! :manage, self
    @metric = Metric.find(params[:id])
  end

  def create
    authorize! :manage, self
    @metric = Metric.new(params[:metric])

    respond_to do |format|
      if @metric.save
        format.html { redirect_to @metric, notice: 'A metrica foi cadastrada com sucesso.' }
        format.json { render json: @metric, status: :created, location: @metric }
      else
        format.html { render action: "new" }
        format.json { render json: @metric.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :manage, self
    @metric = Metric.find(params[:id])

    respond_to do |format|
      if @metric.update_attributes(params[:metric])
        format.html { redirect_to metrics_path, notice: "A métrica #{@metric.name} foi atualizada com sucesso." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @metric.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize! :read, self
    @metric = Metric.find(params[:id])
    @thresholds = Threshold.all
  end

end
