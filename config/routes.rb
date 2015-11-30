Rails.application.routes.draw do

  devise_for :users, :path_names => {:sign_up => "new", :sign_out => 'logout', 
                                     :sign_in => 'login' }                                
  devise_scope :user do
    match  '/login'   => 'devise/sessions#new',        via: 'get'
    match  '/logout'  => 'devise/sessions#destroy',    via: 'delete'
  end
  
  resources :agencies, path: '/admin/agencies', only: [:edit, :update] do
    resources :branches, only: [:create, :new]
  end
  resources :branches, path: '/admin/branches', 
                       only: [:show, :edit, :update, :destroy]
  
  root 'main#index'
  
  get 'agency_admin/home', path: '/admin/agency_admin/home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
=begin
  resources :main
  resources :user do
    collection do
      post 'login'
      get 'login'
      get 'recover'
    end
    member do
      get 'activate' => 'user#activate', as: :activate
    end
    #member do
    #  get 'new'
    #  post 'create'
    #  get 'edit'
    #  get 'show'
    #end
  end
  resources :jobseeker, controller: 'user'
=end
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
