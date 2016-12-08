class JobSeekersController < ApplicationController
  before_action :user_logged!, except: [:new, :create]
  include UserParameters

  def new
    @jobseeker = JobSeeker.new
    @jobseeker.build_address
    authorize @jobseeker
  end

  def create
    jobseeker_params = form_params
    dispatch_file    = jobseeker_params.delete 'resume'

    @jobseeker = JobSeeker.new(jobseeker_params)
    authorize @jobseeker
    models_saved = @jobseeker.save

    if models_saved
      if dispatch_file          # If there is a resume, try to save that
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
      flash[:notice] = 'A message with a confirmation and link has been sent to
      your email address. ' \
                       'Please follow the link to activate your account.'
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @current_resume = @jobseeker.resumes[0]
  end

  def update
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    jobseeker_params = handle_user_form_parameters(permitted_attributes(@jobseeker))
    dispatch_file    = jobseeker_params.delete 'resume'

    models_saved = @jobseeker.update_attributes(jobseeker_params)

    if models_saved
      if dispatch_file          # If there is a resume, try to save/update that
        tempfile = dispatch_file.tempfile
        filename = dispatch_file.original_filename

        # Update current resume if present, otherwise save new
        # (Statement below needs to change if more than one resume per JS)
        resume = @jobseeker.resumes[0]
        if resume
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
      sign_in :user, @jobseeker.user, bypass: true if pets_user == @jobseeker
      flash[:notice] = 'Jobseeker was updated successfully.'
      redirect_to(@jobseeker)
      return if (pets_user == @jobseeker.case_manager) || (pets_user == @jobseeker.job_developer)
      redirect_to root_path
    else
      @resume = resume
      render 'edit'
    end
  end

  def home
    @jobseeker = JobSeeker.find(params[:id])
    @recent_jobs_type = 'recent-jobs'
    authorize @jobseeker
    @newjobs = Job.new_jobs(@jobseeker.last_sign_in_at).paginate(page: params[:page], per_page: 5)
    @js_last_sign_in = @jobseeker.last_sign_in_at
    @application_type = 'job_seeker'
  end

  def index
    @jobseeker = JobSeeker.all
    authorize @jobseeker
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @application_type = 'job_seeker'
  end

  def preview_info
    raise 'Unsupported request' unless request.xhr?
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    render partial: '/job_seekers/info', locals: { job_seeker: @jobseeker,
                                                   preview_mode: true,
                                                   offer_download: false }
  end

  def destroy
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @jobseeker.destroy
    flash[:notice] = 'Jobseeker was deleted successfully.'
    redirect_to root_path
  end

  def list_match_jobs
    @jobseeker = JobSeeker.find(params[:id])
    if @jobseeker.resumes.empty?
      flash[:error] =
        "#{@jobseeker.full_name(last_name_first: false)} " \
        'does not have a resume on file'
      redirect_to(root_path)
    else
      @star_rating = JobCruncher.match_jobs(@jobseeker.resumes[0].id).to_h
      @list_jobs = Job.all.where(id: @star_rating.keys).includes(:company)
                      .sort { |x, y| @star_rating[y.id] <=> @star_rating[x.id] }
                      .paginate(page: params[:jobs_page], per_page: 20)
    end
  end

  private

  def form_params
    params.require(:job_seeker).permit(:first_name,
                                       :last_name, :email, :phone,
                                       :password,
                                       :password_confirmation,
                                       :year_of_birth,
                                       :resume,
                                       :consent,
                                       :job_seeker_status_id,
                                       address_attributes: [:id, :street, :city,
                                                            :zipcode, :state])
  end
end
