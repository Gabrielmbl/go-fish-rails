Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root to: "games#index"

  get 'stats', to: 'pages#stats', as: 'stats'

  get 'history', to: 'pages#history', as: 'history'

  get 'status', to: 'pages#status', as: 'status'

  resources :games do
    resources :game_users, only: %i[create destroy]
    resources :rounds, only: %i[create]
  end
end
