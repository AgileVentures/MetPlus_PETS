class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    PusherManager.trigger_event(:USER_LOGIN,
          person_id: current_user.actable.id) if user_signed_in?
  end

  # DELETE /resource/sign_out
  def destroy
    super
    # Remove cookies data
    cookies.delete :person_id
    cookies.delete :person_type
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
