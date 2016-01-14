class JobSeekersController < ApplicationController

  def new
    @jobseeker = JobSeeker.new
  end

  def create
    @jobseeker = JobSeeker.new(jobseeker_params)
    if @jobseeker.save
      flash[:notice] = "A message with a confirmation and link has been sent to your email address. " +
                       "Please follow the link to activate your account."
      redirect_to root_path
    else
      @model_errors = @jobseeker.errors
      render 'new'
    end

  end

  def edit
    @jobseeker = JobSeeker.find(params[:id])
  end

  def update
    @jobseeker = JobSeeker.find(params[:id])

    if @jobseeker.update_attributes(jobseeker_params)
      sign_in :user, @jobseeker.user, bypass: true
      flash[:notice] = "Jobseeker was updated successfully."
      redirect_to root_path
    else
      @model_errors = @jobseeker.errors
      render 'edit'
    end
  end

  def index
    @jobseeker = JobSeeker.all
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
  end

  def destroy
    @jobseeker = Jobseeker.find(params[:id])
    @jobseeker.destroy
    flash[:notice] = "Jobseeker was deleted successfully."
    redirect_to root_path
  end

  private
   def jobseeker_params
     params.require(:job_seeker).permit(:first_name,
            :last_name, :email, :phone,
            :password,
            :password_confirmation,
            :year_of_birth,
            :resume)
   end
end
