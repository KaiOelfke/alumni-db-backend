Rails.application.routes.draw do

  # devise token
  mount_devise_token_auth_for 'User', at: '/auth', controllers: {
    registrations:  'users/registrations',
    confirmations: 'users/confirmations'
  }
  
=begin
  devise_scope :user do
    get '/auth/confirmation', to: 'devise_token_auth/confirmations#show'
    post '/auth/confirmation', to: 'users/confirmations#create'
  end
=end


  get 'search', to: 'search#search'

  put 'users', to: 'users#update'



  resources :users, only: [:show, :index]

  namespace :subscriptions do

    resources :discounts, :plans, only: [:index, :show, :update, :create, :destroy]
  end

  scope module: 'subscriptions' do
    get '/subscriptions/client_token', to: 'subscriptions#client_token'
    get '/subscriptions/discounts/check', to: 'discounts#check'
    resources :subscriptions, only: [:show, :destroy]
    resource :subscriptions, only: [:create]
  end

  namespace :events do
    resources :fees, only: [:index, :show, :update, :create, :destroy]
  end

  scope module: 'events' do

    resources :events, only: [:index, :show, :update, :create, :destroy]  do
      resources :participations, only: [:index, :show, :update, :create, :destroy]
      resources :applications, only: [:index, :create]
      get '/fee_codes', to: 'fee_codes#all_codes_for_event'
      get '/validate_code', to: 'fee_codes#validate_code'
    end
    resources :fee_codes, only: [:index, :show, :create, :destroy]
  end
  

  #


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
