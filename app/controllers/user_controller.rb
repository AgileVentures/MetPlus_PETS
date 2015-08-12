class UserController < ApplicationController
  def new
    getUser
    respond_to do |format|
      format.html {render partial: 'new', layout: 'modal'}
    end
  end

  def create
    getUser
    sleep 5.seconds
    @user = @user_class.new
    @user.update_attributes filter_params
    respond_to do |format|
      if @user.save
        flash[:success] = 'Registration successful, you will receive one email to active your account!'
        #format.html {redirect_to root_path}
        format.all { render json: {:url => root_path}, status: :ok }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js   { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def show
  end

  def login
    respond_to do |format|
      format.html do
        @modal_title = 'Login'
        render partial: 'login', layout: 'modal'
      end
    end
  end

  private
  def getUser
    case request.original_fullpath
      when /jobseeker/
        @user = JobSeeker.new
        @url = jobseeker_index_path
        @user_class = JobSeeker
        @params_key = :job_seeker
    end
  end
  def filter_params
    params.require(@params_key).permit(:first_name,
                                       :last_name,
                                       :email,
                                       :password,
                                       :password_confirmation)
  end
end
