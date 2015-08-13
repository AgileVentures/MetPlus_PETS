class SessionController < ApplicationController
  def new
  end

  def create
    user = User.login(params[:email], params[:password])
    # If the user exists AND the password entered is correct.
    if user
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = user.id
      redirect_to root_path
    else
      # If user's login doesn't work, send them back to the login form.
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
