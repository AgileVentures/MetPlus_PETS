Rails.application.routes.draw do
  devise_for :users, path_names: { sign_up: 'new', sign_out: 'logout',
                                   sign_in: 'login' },
                     controllers: { invitations: 'people_invitations',
                                    sessions: 'users/sessions',
                                    confirmations: 'users/confirmations' }

  devise_scope :user do
    match  '/login'   => 'users/sessions#new',        via: 'get'
    match  '/logout'  => 'users/sessions#destroy',    via: 'get'
  end

  get 'about', to: 'pages#about'
  match 'contact', to: 'pages#contact', via: [:get, :post]

  # ----------------------- Agency Branches ----------------------------------
  # Agency admin can create a branch within the agency
  resources :agencies, path: '/admin/agencies', only: [:edit, :update] do
    resources :branches, only: [:create, :new]
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
      get :edit_profile, to: 'agency_people#edit_profile'
      get :my_profile
      patch :update_profile, to: 'agency_people#update_profile'
      patch 'assign_job_seeker/:job_seeker_id/:agency_role',
            to: 'agency_people#assign_job_seeker',
            as: 'assign_job_seeker'
    end
  end

  get 'agency_people/:id/list_js_cm/:people_type' =>
             'agency_people#list_js_cm', as: :list_js_cm_agency_people

  get 'agency_people/:id/list_js_jd/:people_type' =>
             'agency_people#list_js_jd', as: :list_js_jd_agency_people

  get 'agency_people/:id/list_js_without_jd/:people_type' =>
              'agency_people#list_js_without_jd', as: :list_js_without_jd_agency_people

  get 'agency_people/:id/list_js_without_cm/:people_type' =>
              'agency_people#list_js_without_cm', as: :list_js_without_cm_agency_people

  get 'agency_people/:id/my_js_as_jd' => 'agency_people#my_js_as_jd', as: :my_js_as_jd

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
  # agency admin. Delete of a company can only be performed by an agency admin.

  resources :companies, only: [:show, :edit, :update, :destroy] do
    member do
      get 'list_people' => 'companies#list_people', as: :list_people
    end
  end

  # --------------------------------------------------------------------------

  # ----------------------- Company People -----------------------------------
  # Company admin (and agency admin) can edit and delete a company person
  resources :company_people, path: '/company_admin/company_people',
                             only: [:show, :edit, :update, :destroy]

  resources :company_people, only: [] do
    member do
      get 'edit_profile', as: :edit_profile
      patch 'update_profile', as: :update_profile
      get 'my_profile', as: :my_profile
      get 'home', as: :home
    end
  end

  # --------------------------------------------------------------------------

  # ----------------------- Agency Admin -------------------------------------
  # Agency admin maintains agency information
  get 'agency_admin/home',           :as => '/agency_admin/home', to: 'agency_admin#home'
  get 'agency_admin/job_properties', :as => '/agency_admin/job_properties', to: 'agency_admin#job_properties'
  # --------------------------------------------------------------------------

  # ----------------------- Job Categories  ----------------------------------
  resources :job_categories, only: [:create, :show, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Skills -------------------------------------------
  resources :skills, only: [:create, :show, :update, :destroy]
  # --------------------------------------------------------------------------

  # ----------------------- Licenses -------------------------------------------
  resources :licenses, only: [:create, :show, :update, :destroy]
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

  get 'agency/:id',  :as => 'agency/home', to: 'agency_admin#home'

  get 'company/:id', :as => 'company/home', to: 'company_people#home'

  # ------------------------------ Jobs ----------------------------------------
  get 'jobs/list/:job_type'         => 'jobs#list',   as: :list_jobs
  get 'jobs/:job_id/apply/:user_id' => 'jobs#apply',  as: :apply_job
  get 'jobs/update_addresses'       => 'jobs#update_addresses',
      as: :update_addresses

  resources :jobs do
    patch 'revoke',            on: :member, as: :revoke
    get 'match_resume',        on: :member, as: :match_resume
    get 'match_job_seekers',   on: :member, as: :match_job_seekers
    get :notify_job_developer, on: :member, as: :notify_jd
    get 'match_jd_job_seekers', on: :member, as: :match_jd_job_seekers
  end
  # --------------------------------------------------------------------------

  # --------------------------- Job Applications -----------------------------
  patch 'job_applications/:id/accept' => 'job_applications#accept',
        as: :accept_application
  patch 'job_applications/:id/reject' => 'job_applications#reject',
        as: :reject_application
  patch 'job_applications/:id/process' => 'job_applications#process_application',
        as: :process_application
  get 'job_applications/:id' => 'job_applications#show',
      as: :application
  get 'job_applications/:type/:entity_id' => 'job_applications#list',
      as: :list_applications
  # --------------------------------------------------------------------------

  # ---------------------------- Job Seekers ---------------------------------
  resources :job_seekers do
    get 'home', on: :member, as: :home
    get 'match_jobs', on: :member, as: :match_jobs
    get 'list_match_jobs', on: :member, as: :list_match_jobs
    get 'my_profile', on: :member, as: :my_profile
  end

  get 'job_seekers/:id/preview_info', to: 'job_seekers#preview_info'
  get 'job_seekers/:id(/download_resume/:resume_id)', to:
    'job_seekers#download_resume',
      as: :download_resume
end
