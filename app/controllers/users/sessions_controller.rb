class Users::SessionsController < Devise::SessionsController
  require 'pusher_manager'
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    # Add data to cookies - to be used by pusher controller in client
    if user_signed_in?
      cookies[:person_id]   = current_user.actable_id
      cookies[:person_type] = current_user.actable_type
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
    # Remove cookies data associated with logged-in user
    cookies.delete :person_id
    cookies.delete :person_type
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
