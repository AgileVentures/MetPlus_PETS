class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  class ApplicationController::AuthorizationException < Exception

  end

  protect_from_forgery with: :exception
  helper_method :pets_user

  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_current_location, :unless => :devise_controller?


  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ApplicationController::AuthorizationException, with: :user_not_authenticated

  def after_sign_in_path_for(resource)
    person = resource.pets_user
    case person
      when JobSeeker
        return home_job_seeker_path(person)
      when CompanyPerson
        return home_company_person_path(person)
    end
    stored_location_for(resource) || request.referer || root_path
  end


  protected

    def pets_user
       return nil if current_user.nil?
       current_user.try(:actable).nil? ? current_user : current_user.actable
    end
    def store_current_location
      store_location_for(:user, request.url)
    end

    def configure_permitted_parameters
      [:first_name,:last_name, :phone].each do |field|
        devise_parameter_sanitizer.for(:account_update)<<field
        devise_parameter_sanitizer.for(:sign_up)<<field
      end
    end

    def user_logged!
      raise ApplicationController::AuthorizationException, "must be logged in" unless pets_user
    end

    def user_not_authorized
      if request.xhr?
        return render json: {:message => 'You are not authorized to perform this action.'}, status: 403
      else
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to(request.referrer || root_path)
      end
    end

    def user_not_authenticated
      if request.xhr?
        return render json: {:message => 'You need to login to perform this action.'}, status: 401
      else
        flash[:alert] = "You need to login to perform this action."
        redirect_to(request.referrer || root_path)
      end
    end
end
