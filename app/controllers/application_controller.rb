class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name    
    devise_parameter_sanitizer.for(:sign_up) << :phone

    ["first_name","last_name", "phone"].each{ |field|
      devise_parameter_sanitizer.for(:account_update)<<field.to_sym 
    }

  end
end
