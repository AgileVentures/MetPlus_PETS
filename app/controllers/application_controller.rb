class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_current_location, :unless => :devise_controller?


  protected
    def store_current_location
      store_location_for(:user, request.url)
    end

    def configure_permitted_parameters
      [:first_name,:last_name, :phone].each do |field|
        devise_parameter_sanitizer.for(:account_update)<<field
        devise_parameter_sanitizer.for(:sign_up)<<field
      end
    end
end
