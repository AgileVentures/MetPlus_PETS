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

    person_params = jobseeker_params
    if person_params['password'].to_s.length == 0
       person_params.delete('password')
       person_params.delete('password_confirmation')
    end

    if @jobseeker.update_attributes(person_params)
       sign_in :user, @jobseeker.user, bypass: true
       flash[:notice] = "Jobseeker was updated successfully."
       redirect_to root_path
    else
       @model_errors = @jobseeker.errors
       render 'edit'
    end
  end

  def home
    @jobseeker = JobSeeker.find(params[:id])
    @newjobs = Job.new_jobs(@jobseeker.last_sign_in_at).paginate(:page => params[:page], :per_page => 5)
    @past_week = Job.new_jobs(Time.now - 3.weeks).paginate(:page => params[:page], :per_page => 5)

  end

  def index
    @jobseeker = JobSeeker.all
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
  end

  def destroy
    @jobseeker = JobSeeker.find(params[:id])
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
            :job_seeker_status_id,
            :resume)

   end
end
