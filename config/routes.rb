

Rails.application.routes.draw do

  resources :group_contacts

  resources :contacts

  resources :events

  devise_scope :user do
    match 'users/sign_out', :to => 'users/sessions#destroy', :via => :delete
  end

  devise_for :users, :controllers => {:sessions => "users/sessions", :registrations => "users/registrations", :passwords => "users/passwords"}
  root :to => "home#index"

  ## API FOR USER
  match 'users/list_parent', :to => "users#list_parent", :via => :get
  match 'users/create_parent', :to => "users#create_parent", :via => :post
  match 'emergency', :to => "emergency#emergency", :via => :post
  match 'emergency/:id', :to => "emergency#update_message", :via => :put
  match 'emergency/:id', :to => "emergency#delete_message", :via => :delete
  match 'emergency/:id', :to => "emergency#show_message", :via => :get
  match 'users/:id', :to => "users#show", :via => :get
  match 'users/:id', :to => "users#update", :via => :put
  match 'users/:id', :to => "users#destroy", :via => :delete

  ## API FOR EVENT
  match 'event/list_event_on_range_date', :to => "events#get_event_from_date_to_date", :via => :get, :as => :list_event_on_range_date


  # Of course, you need to substitute your application name here, a block
  # like this probably already exists.
  require 'resque/server'
  mount Resque::Server.new, at: "/resque"

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
