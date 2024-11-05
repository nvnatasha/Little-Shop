Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do 
    namespace :v1 do
      resources :items, only: [:index, :show, :create, :destroy] do
        get '/merchant', to: "merchants#show"
      end
      resources :merchants do
        resources :invoices, only: [:index, :create]
        resources :items, only: [:index]
      end
      resources :invoices, only: [:show]
      resources :customers, except: [:index, :show, :create, :update, :destroy] do
        resources :invoices, only: [:index]
      end
    end
  end
end