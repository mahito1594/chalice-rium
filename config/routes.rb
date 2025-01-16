Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "dungeons#index"

  # Routes for the static resources
  get "about" => "static_pages#about", as: :about
  get "terms" => "static_pages#terms", as: :terms

  # Custom routes for users
  resources :users, param: :username, only: %i[show edit update destroy]

  # TODO: treat this as a member route of users
  resources :dungeons, only: %i[show new create edit update destroy]

  # Letter opener for development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
