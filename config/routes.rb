# frozen_string_literal: false

Rails.application.routes.draw do
  resources :scores, only: %i[index create show destroy]

  get 'players/:name', to: 'players#show'
end
