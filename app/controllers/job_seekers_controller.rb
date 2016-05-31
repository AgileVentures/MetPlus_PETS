class JobSeekersController < ApplicationController

  include UserParameters
  include JobApplicationsViewer

  def new
    @jobseeker = JobSeeker.new
  end

  def create
    jobseeker_params = form_params
    dispatch_file    = jobseeker_params.delete 'resume'

    @jobseeker = JobSeeker.new(jobseeker_params)
    models_saved = @jobseeker.save

    if models_saved
      if dispatch_file          # If there is a résumé, try to save that
        tempfile = dispatch_file.tempfile
        filename = dispatch_file.original_filename

        resume = Resume.new(file: tempfile, file_name: filename,
                            job_seeker_id: @jobseeker.id)
        unless resume.save
          models_saved = false
          @jobseeker.destroy
          @jobseeker.errors.messages.merge! resume.errors.messages
        end
      end
    end

    if models_saved
      flash[:notice] = "A message with a confirmation and link has been sent to your email address. " +
                       "Please follow the link to activate your account."
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @jobseeker = JobSeeker.find(params[:id])
    @current_resume = @jobseeker.resumes[0]
  end

  def update
    @jobseeker = JobSeeker.find(params[:id])

    jobseeker_params = handle_user_form_parameters form_params
    dispatch_file    = jobseeker_params.delete 'resume'

    models_saved = @jobseeker.update_attributes(jobseeker_params)

    if models_saved
      if dispatch_file          # If there is a résumé, try to save/update that
        tempfile = dispatch_file.tempfile
        filename = dispatch_file.original_filename

        # Update current résumé if present, otherwise save new
        # (Statement below needs to change if more than one resume per JS)
        resume = @jobseeker.resumes[0]
        if (resume)
          resume.file_name = filename
          resume.file = tempfile
        else
          resume = Resume.new(file: tempfile, file_name: filename,
                     job_seeker_id: @jobseeker.id)
        end

        unless resume.save
          models_saved = false
          @jobseeker.errors.messages.merge! resume.errors.messages
        end
      end
    end


    if models_saved
       sign_in :user, @jobseeker.user, bypass: true
       flash[:notice] = "Jobseeker was updated successfully."
       redirect_to root_path
    else
       @resume = resume
       render 'edit'
    end
  end

  def home
    @jobseeker = JobSeeker.find(params[:id])
    @newjobs = Job.new_jobs(@jobseeker.last_sign_in_at).paginate(:page => params[:page], :per_page => 5)
    @past_week = Job.new_jobs(Time.now - 3.weeks).paginate(:page => params[:page], :per_page => 5)

    @application_type = params[:application_type] || 'my-applied'
  end

  def index
    @jobseeker = JobSeeker.all
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
    @application_type = params[:application_type] || 'js-applied'
  end

  def applied_jobs
    raise 'Unsupported request' if not request.xhr?

    @application_type = params[:application_type] || 'my-applied'

    @job_applications = []
    @job_applications = display_job_applications @application_type, 5,
                                                 params[:id]
    render partial: 'jobs/applied_job_list',
          :locals => {job_applications: @job_applications,
                      application_type: @application_type}
	end

  def destroy
    @jobseeker = JobSeeker.find(params[:id])
    @jobseeker.destroy
    flash[:notice] = "Jobseeker was deleted successfully."
    redirect_to root_path
  end

  private
   def form_params
     params.require(:job_seeker).permit(:first_name,
            :last_name, :email, :phone,
            :password,
            :password_confirmation,
            :year_of_birth,
            :resume,
            :job_seeker_status_id,
            address_attributes: [:id, :street, :city, :zipcode, :state])
   end
end
