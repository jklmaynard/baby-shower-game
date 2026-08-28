Rails.application.routes.draw do
  root "registrations#new"

  resources :registrations, only: [ :new, :create ]
  resources :sessions, only: [ :new, :create, :destroy ]
  get "/game", to: "game#index", as: :game
  get "/leaderboard", to: "leaderboard#index", as: :leaderboard

  namespace :api do
    resources :answers, only: [ :create, :index ]
    resources :questions, only: [ :index ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
