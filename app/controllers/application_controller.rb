class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  class ApplicationController::AuthorizationException < Exception
  end

  protect_from_forgery with: :exception

  def redirect_back_or_default(default = root_path)
    redirect_to (request.referer.present? ? :back : default)
  end

  helper_method :pets_user, :current_agency, :determine_if_admin

  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_current_location, :unless => :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ApplicationController::AuthorizationException, with: :user_not_authenticated
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Authorization::NotAuthorizedError, with: :user_not_authorized

  def after_sign_in_path_for(resource)
    person = resource.pets_user
    case person
    when JobSeeker
      return home_job_seeker_path(person)
    when CompanyPerson
      return home_company_person_path(person)
    when AgencyPerson
      return home_agency_person_path(person)
    end
    stored_location_for(resource) || request.referer || root_path
  end

  protected

  def action_description
    @description ||= 'perform this action'
  end

  def action_description= description
    @description = description
  end

  def pets_user
    return nil unless current_user

    current_user.actable || current_user
  end

  def store_current_location
    store_location_for(:user, request.url)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
  end

  def user_logged!
    raise ApplicationController::AuthorizationException, 'must be logged in' unless pets_user
  end

  def record_not_found(e)
    redirect_to((request.referer.present? ? :back : root_path),
                alert: e.message)
  end

  def user_not_authorized
    msg = action_description
    if request.xhr?
      return render json: { :message => "You are not authorized to #{msg}." }, status: 403
    else
      flash[:alert] = "You are not authorized to #{msg}."
      redirect_to(request.referrer || root_path)
    end
  end

  def user_not_authenticated
    msg = action_description
    if request.xhr?
      return render json: { :message => "You need to login to #{msg}." }, status: 401
    else
      flash[:alert] = "You need to login to #{msg}."
      redirect_to(request.referrer || root_path)
    end
  end

  def current_agency
    if pets_user.is_a? AgencyPerson
      return pets_user.agency
    else
      ## This branch need to be changed when we have multi agencies
      return Agency.first
    end
  end

  def determine_if_admin person
    # returns 1) true/false depending on whether or not person is agency admin,
    #         2) true/false depending on whether or not person is company admin
    aa = person.agency_admin?(current_agency)
    ca = aa ? false : person.company_admin?(@company)

    return aa, ca
  end
end
