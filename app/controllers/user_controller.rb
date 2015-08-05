class UserController < ApplicationController
  def new
    getUser
  end

  def create
    getUser
    begin
      @user = @userClass.new params[:user]
      @user.save!
    rescue
      puts "Error #{$!}"
      render :new
      return
    end
    redirect_to root_path
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
    end
  end
end
