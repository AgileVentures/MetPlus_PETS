class SessionController < ApplicationController

  def create
    email = params[:user][:email]
    password = params[:user][:password]
    begin
      user = User.login!(email, password)
      session[:user_id] = user.id
    rescue Exceptions::User::AuthenticationError => e
      flash[:errors] = e.to_s
    end
    respond_to do |format|
      format.html {redirect_to root_path}
      if session[:user_id] != nil
        format.json {render :json => {url: root_path}, status: :ok}
      else
        format.json {render :json => {errors: flash[:errors]}, status: :unauthorized}
      end
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
