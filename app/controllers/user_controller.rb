class UserController < ApplicationController
  def new
    case request.original_fullpath
      when /jobseeker/
        @user = JobSeeker.new
        @url = jobseeker_index_path
    end
  end

  def create
  end

  def edit
  end

  def show
  end
end
