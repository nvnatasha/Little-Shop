Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index

  
  get '/api/v1/merchants/find', to: 'api/v1/merchants#find'
  get '/api/v1/items/find_all', to: 'api/v1/items#find_all'

  get '/api/v1/items',     to: 'api/v1/items#index'
  get '/api/v1/items/:id', to: 'api/v1/items#show'
  post '/api/v1/items', to: 'api/v1/items#create'
  patch '/api/v1/items/:id', to: 'api/v1/items#update'

  get "/api/v1/merchants", to: "api/v1/merchants#index"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"
  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"

  get '/api/v1/merchants/:merchant_id/customers', to: 'api/v1/customers#index'
  get '/api/v1/merchants/:merchant_id/customers/:id', to: 'api/v1/customers#show'
  get '/api/v1/merchants/:merchant_id/invoices', to: 'api/v1/invoices#index'

  get '/api/v1/invoices/:id', to: 'api/v1/invoices#show'  
  get "/api/v1/customers/:customer_id/invoices", to: 'api/v1/invoices#index'

  get "/api/v1/merchants/:id/items", to: 'api/v1/items#index'
  get '/api/v1/items/:item_id/merchant', to: "api/v1/merchants#show"
  delete '/api/v1/items/:id', to: 'api/v1/items#destroy'

  get '/api/v1/merchants/:merchant_id/coupons', to: 'api/v1/coupons#index'
  get '/api/v1/merchants/:merchant_id/coupons/:id', to: 'api/v1/coupons#show'
  post '/api/v1/merchants/:merchant_id/coupons', to: 'api/v1/coupons#create'
  patch '/api/v1/merchants/:merchant_id/coupons/:id', to: 'api/v1/coupons#update'
  patch '/api/v1/merchants/:merchant_id/coupons/:id/activate', to: 'api/v1/coupons#activate'
end