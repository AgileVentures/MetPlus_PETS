Rails.application.routes.draw do

  devise_for :users, :path_names => {:sign_up => "new", :sign_out => 'logout',
                                     :sign_in => 'login' },
                :controllers => { :invitations   => 'people_invitations',
                                  :sessions      => 'users/sessions',
                                  :confirmations => 'users/confirmations'}

  devise_scope :user do
    match  '/login'   => 'users/sessions#new',        via: 'get'
    match  '/logout'  => 'users/sessions#destroy',    via: 'delete'
  end

  # ----------------------- Agency Branches ----------------------------------
  # Agency admin can create a branch within the agency
  resources :agencies, path: '/admin/agencies', only: [:edit, :update] do
    resources :branches,      only: [:create, :new]
  end
  # Agency admin can edit and delete a branch
  resources :branches, path: '/admin/branches',
                       only: [:show, :edit, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Agency People ------------------------------------
  # Agency admin can edit and delete an agency person
  resources :agency_people, path: '/admin/agency_people',
                       only: [:show, :edit, :update, :destroy]

  resources :agency_people do
    get 'edit_profile', on: :member, as: :edit_profile
    patch 'update_profile', on: :member, as: :update_profile
  end
  # --------------------------------------------------------------------------

  # ----------------------- Company Registration -----------------------------
  # Only agency admin can edit, destroy and approve/deny company registration
  resources :company_registrations, path: 'admin/company_registrations',
                                only: [:edit, :update, :destroy, :show] do
    patch 'approve', on: :member, as: :approve
    patch 'deny',    on: :member, as: :deny
  end
  # Any PETS visitor can create a company registration request
  resources :company_registrations, only: [:new, :create]
  # --------------------------------------------------------------------------

  # ----------------------- Company ------------------------------------------
  # Company admin (and agency admin) can edit a company
  resources :companies, path: 'company_admin/companies',
                                only: [:edit, :update, :show]
  # Only the agency admin can delete a company
  resources :companies, path: 'admin/companies',
                                only: [:destroy, :list]
  # --------------------------------------------------------------------------

  # ----------------------- Company People -----------------------------------
  # Company admin (and agency admin) can edit and delete a company person
  resources :company_people, path: '/company_admin/company_people',
                       only: [:show, :edit, :update, :destroy]

  resources :company_people do
     get 'edit_profile', on: :member, as: :edit_profile
     patch 'update_profile', on: :member, as: :update_profile
  end
  # --------------------------------------------------------------------------

  # ----------------------- Agency Admin -------------------------------------
  # Agency admin maintains agency information
  get 'agency_admin/home',           path: '/agency_admin/home'
  get 'agency_admin/job_properties', path: '/agency_admin/job_properties'
  # --------------------------------------------------------------------------

  # ----------------------- Job Categories  ----------------------------------
  resources :job_categories, only: [:create, :edit, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Skills -------------------------------------------
  resources :skills, only: [:create, :edit, :update, :destroy]
  # --------------------------------------------------------------------------

  root 'main#index'

  get 'agency/home',  path: '/agency/:id'

  get 'company/home', path: '/company/:id'

  resources :jobs

  resources :job_seekers
  get 'job_seekers/home',  path: '/job_seekers/:id/home'

   # The priority is based upon order of creation: first created -> highest priority.

  # ----------------------- end of customizations ------------------------------
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
