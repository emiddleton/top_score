# frozen_string_literal: false

require 'pagy/extras/headers'

class PlayersController < ApplicationController
  # GET /players/:name
  def show
    player = Player.find_by!(name: params[:name])
    render json: player, status: :ok
  end
end
