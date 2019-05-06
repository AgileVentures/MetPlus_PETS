class Users::SessionsController < Devise::SessionsController
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
      if current_user.respond_to?(:remember_me) && current_user.remember_me
        cookies[:user_id]     = { value: current_user.id,
                                  expires: 1.year.from_now }
        cookies[:person_type] = { value: current_user.actable_type,
                                  expires: 1.year.from_now }
      else
        cookies[:user_id]     = current_user.id
        cookies[:person_type] = current_user.actable_type
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
    # Remove cookies data
    cookies.delete :user_id
    cookies.delete :person_type
  end
end
