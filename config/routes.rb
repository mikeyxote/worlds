Rails.application.routes.draw do
  resources :teams
  get 'team/view'

  get 'recommend/create'

  get 'strava/download'

  resources :points
  resources :events
  resources :series
  resources :connections
  
  resources :events do
    member do
      get :features
      get :participations
      get :connections
    end
  end
  
  resources :activities do
    member do
      get :load_efforts
    end
  end
  
  resources :efforts
  resources :segments
  resources :segments do
    member do
      get :featured_by
    end
  end
  resources :managements,     only: [:create, :destroy]
  resources :features,        only: [:create, :destroy]
  resources :participations,  only: [:create, :destroy]
  resources :connections,     only: [:create, :destroy]
  resources :races,           only: [:create, :destroy]
  
  get 'strava_request/show'
  get 'strava_callback/show'
  get 'download_strava' => 'strava#download'

  devise_for :users
  get 'static_pages/home'
  get 'help' => 'static_pages#help'
  get 'users' => 'users#index'

  get 'static_pages/help'
  get 'strava_request' => 'strava_request#show'
  get 'strava_callback' => 'strava_callback#show'

  resources :users

  resources :users do
    member do
      get :managing, :managers
    end
  end

  root 'static_pages#home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


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
