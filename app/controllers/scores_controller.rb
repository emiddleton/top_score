# frozen_string_literal: false

require 'pagy/extras/headers'

class ScoresController < ApplicationController
  # GET /scores
  def index
    @q = Score.includes(:player).joins(:player).ransack(params[:q])
    @pagy, @scores = pagy(@q.result(distinct: true), items: 50)
    pagy_headers_merge(@pagy)
    render json: @scores, status: :ok
  end

  # POST /scores
  def create
    score = Score.create!(score_params)
    render json: score, status: :created
  end

  # GET /scores/:id
  def show
    score = Score.find(params[:id])
    render json: score, status: :ok
  end

  # DELETE /scores/:id
  def destroy
    score = Score.find(params[:id])
    score.destroy
    head :no_content
  end

  private

  def score_params
    params.require(:score).permit(:name, :score, :time)
  end
end
