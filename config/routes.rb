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

  resources :agency_people, only: [] do
    member do
      get :home
      get :edit_profile,   to: 'agency_people#edit_profile'
      patch :update_profile, to: 'agency_people#update_profile'
      patch 'assign_job_seeker/:job_seeker_id/:agency_role',
                        to: 'agency_people#assign_job_seeker',
                        as: 'assign_job_seeker'
    end
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
  # Most company actions can be performed by a company admin or an
  # agency admin.  Redirect logic after actions can be different
  # depending on which admin type is performing the action.
  # (delete of a company can only be performed by an agency admin, but
  # 'admin_type param is still used to conform to Rails path conventions')

  get    'companies/:id/:admin_type'  => 'companies#show', as: :company
  patch  'companies/:id/:admin_type'  => 'companies#update'
  delete 'companies/:id/:admin_type'  => 'companies#destroy'
  get    'companies/:id/edit/:admin_type' => 'companies#edit',
                            as: :edit_company

  # --------------------------------------------------------------------------

  # ----------------------- Company People -----------------------------------
  # Company admin (and agency admin) can edit and delete a company person
  resources :company_people, path: '/company_admin/company_people',
                       only: [:show, :edit, :update, :destroy]

  resources :company_people do
     get 'edit_profile', on: :member, as: :edit_profile
     patch 'update_profile', on: :member, as: :update_profile
     get 'home', on: :member, as: :home
  end

  get 'company_people/:company_id/list_people/:people_type' =>
              'company_people#list_people', as: :list_company_people

  # --------------------------------------------------------------------------

  # ----------------------- Agency Admin -------------------------------------
  # Agency admin maintains agency information
  get 'agency_admin/home',           path: '/agency_admin/home'
  get 'agency_admin/job_properties', path: '/agency_admin/job_properties'
  # --------------------------------------------------------------------------

  # ----------------------- Job Categories  ----------------------------------
  resources :job_categories, only: [:create, :show, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Skills -------------------------------------------
  resources :skills, only: [:create, :show, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Tasks --------------------------------------------
  resources :tasks, only: [:index] do
    patch 'assign', on: :member, as: :assign
    patch 'in_progress', on: :member, as: :in_progress
    patch 'done', on: :member, as: :done
    get 'list_owners', on: :member, as: :list_owners
  end
  get 'tasks/tasks/:task_type' => 'tasks#tasks', as: :list_tasks
  patch 'tasks/:id/assign/:to' => 'tasks#assign', as: :assign_tasks
  # --------------------------------------------------------------------------

  root 'main#index'

  get 'agency/home',  path: '/agency/:id'

  get 'company/home', path: '/company/:id'

# ------------------------------ Jobs ----------------------------------------
  get 'jobs/list/:job_type'         => 'jobs#list',   as: :list_jobs
  get 'jobs/:job_id/apply/:user_id' => 'jobs#apply',  as: :apply_job
  get 'jobs/list_search_jobs'       => 'jobs#list_search_jobs',
                                        as: :list_search_jobs
  get 'jobs/update_addresses'       => 'jobs#update_addresses',
                                        as: :update_addresses
  get 'jobs/:id/applications_list/:application_type'  =>
                'jobs#applications_list', as: :applications_list

  resources :jobs do
    get 'applications', on: :member, as: :applications
  end
  # --------------------------------------------------------------------------

  # ---------------------------- Job Seekers ---------------------------------
  resources :job_seekers do
     get 'home', on: :member, as: :home
     get 'match_jobs', on: :member, as: :match_jobs
  end

  get 'job_seekers/:id/applied_jobs/:application_type' =>
                'job_seekers#applied_jobs', as: :applied_jobs_job_seeker
  # --------------------------------------------------------------------------


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
