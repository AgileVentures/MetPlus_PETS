class JobSeekersController < ApplicationController
  before_action :user_logged!, except: [:new, :create]
  include UserParameters

  def new
    @jobseeker = JobSeeker.new
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
      flash[:notice] = 'A message with a confirmation and link has been sent '\
      'to your email address. Please follow the link to activate your account.'
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @jobseeker.build_address unless @jobseeker.address.present?
    @current_resume = @jobseeker.resumes[0]
  end

  def update
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    jobseeker_params = handle_user_form_parameters(permitted_attributes(@jobseeker))
    dispatch_file    = jobseeker_params.delete 'resume'
    jobseeker_params.delete 'address_attributes' if address_is_empty?(jobseeker_params)

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
      bypass_sign_in(@jobseeker.user, scope: :user) if pets_user == @jobseeker
      if @jobseeker.user.unconfirmed_email?
        flash[:warning] = 'Please check your inbox to update your email address'
      else
        flash[:notice] = 'Jobseeker was updated successfully.'
      end
      redirect_to(@jobseeker) && return if (pets_user == @jobseeker.case_manager) ||
                                           (pets_user == @jobseeker.job_developer)
      redirect_to home_job_seeker_path
    else
      @resume = resume
      @jobseeker.build_address unless @jobseeker.address.present?
      render 'edit'
    end
  end

  def home
    @jobseeker = JobSeeker.find(params[:id])
    @recent_jobs_type = 'recent-jobs'
    authorize @jobseeker
    @application_type = 'job_seeker-default'
  end

  def index
    @jobseeker = JobSeeker.all
    authorize @jobseeker
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @offer_download = @jobseeker.resumes.exists? &&
                      (pets_user.is_a?(CompanyPerson) || pets_user.is_a?(AgencyPerson))
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

  def download_resume
    job_seeker = JobSeeker.find(params[:id])
    authorize job_seeker
    resume = Resume.find(params[:resume_id])
    resume_file = ResumeCruncher.download_resume(resume.id)
    raise 'Resume not found in Cruncher' if resume_file.nil?

    send_data resume_file.open.read, filename: resume.file_name
  rescue RuntimeError => e
    flash[:alert] = "Error: #{e}"
    redirect_back_or_default
  ensure
    if resume_file
      resume_file.close
      resume_file.unlink
    end
  end

  def my_profile
    @jobseeker = JobSeeker.find(params[:id])
    authorize @jobseeker
    @current_resume = @jobseeker.resumes[0]
  end

  private

  def address_is_empty?(jobseeker_params)
    address = jobseeker_params[:address_attributes]
    return true unless address

    address[:street].empty? && address[:city].empty? && address[:state].empty?
  end

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
