class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActionController::ParameterMissing, :with => :missing_parameters
  rescue_from ActionController::RoutingError, :with => :error_render_method

  def missing_parameters
    respond_to do |type|
      type.all {
        flash[:error] = 'Invalid form'
        redirect_to :back
      }
      type.all  { render :nothing => true, :status => 400 }
    end
    true
  end

  def error_render_method
    respond_to do |type|
      type.all  { render :template => 'errors/error_404', :status => 404 }
    end
    true
  end
end
