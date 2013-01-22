# coding: utf-8
class ProbesController < ApplicationController
  helper_method :states

  #escopos
  has_scope :by_city
  has_scope :by_state
  has_scope :by_type

  def index
    authorize! :index, self
    @types = [
        { name: "Android", value: "android"},
        { name: "Linux", value: "linux"}
    ]

    @probes = apply_scopes(Probe).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @probes }
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  protected
  def states
    {
        rj: "Rio de Janeiro",
        rs: "Rio Grande do Sul",
        sp: "São Paulo"
    }
  end
end
