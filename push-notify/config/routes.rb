Rails.application.routes.draw do
  devise_for :users
  get 'pages/index'
  root "pages#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :notifications, only: [:create]
    post "notifications/set_token", to: "notifications#set_token"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
