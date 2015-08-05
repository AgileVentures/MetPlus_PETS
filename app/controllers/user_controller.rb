class UserController < ApplicationController
  def new
    getUser
  end

  def create
    getUser
    puts params
    @user = @userClass.new
    @user.update_attributes filter_params
    respond_to do |format|
      if @user.save
        format.html { redirect_to root_path}
      else
        puts 'Failed.......'
        @user.errors.each do |field, value|
          puts "#{field} -> #{value}"
        end
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        # added:
        format.js   { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def show
  end

  private
  def getUser
    case request.original_fullpath
      when /jobseeker/
        @user = JobSeeker.new
        @url = jobseeker_index_path
        @userClass = JobSeeker
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
