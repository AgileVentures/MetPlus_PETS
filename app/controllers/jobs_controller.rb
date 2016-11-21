class JobsController < ApplicationController
  include JobsViewer

  before_action :find_job, only: [:show, :edit, :update, :destroy, :revoke]
  before_action :user_logged!, except: [:index, :list_search_jobs, :show]

  helper_method :job_fields

  def index
    @jobs = policy_scope(Job).order(:title).includes(:company)
            .paginate(page: params[:page], per_page: 20)
  end

  def list_search_jobs
    # Make a copy of q params since we will strip out any commas separating
    # words - need to retain any commas in the form (so user is not surprised)
    q_params = params[:q] ? params[:q].dup : params[:q]

    # Ransack returns a string with all terms entered by the user in
    # a text field.  For "any" or "all" word(s) queries, need to convert
    # that single string into an array of individual words for SQL search.

    @title_words = []
    if q_params && q_params[:title_cont_any]
      q_params[:title_cont_any] =
        q_params[:title_cont_any].split(/(?:,\s*|\s+)/)
      @title_words = q_params[:title_cont_any]
    end

    if q_params && q_params[:title_cont_all]
      q_params[:title_cont_all] =
        q_params[:title_cont_all].split(/(?:,\s*|\s+)/)
      @title_words += q_params[:title_cont_all]
    end

    @description_words = []
    if q_params && q_params[:description_cont_any]
      q_params[:description_cont_any] =
        q_params[:description_cont_any].split(/(?:,\s*|\s+)/)
      @description_words = q_params[:description_cont_any]
    end

    if q_params && q_params[:description_cont_all]
      q_params[:description_cont_all] =
        q_params[:description_cont_all].split(/(?:,\s*|\s+)/)
      @description_words += q_params[:description_cont_all]
    end

    @query = Job.ransack(params[:q]) # For form display of entered values

    @jobs  = Job.ransack(q_params).result(distinct: true)
                .includes(:company)
                .includes(:address)
                .page(params[:page]).per_page(5)
  end

  def new
    @job = Job.new
    authorize @job
    set_company
    set_company_address
  end

  def create
    set_company
    set_company_address
    if pets_user.is_a?(CompanyPerson)
      job_params.merge({'company_person_id' => pets_user.id}) 
    end
    @job = Job.new(job_params)
    authorize @job

    if @job.save
      flash[:notice] = "#{@job.title} has been created successfully."

      obj = Struct.new(:job, :agency)
      Event.create(:JOB_POSTED, obj.new(@job, current_agency))

      redirect_to jobs_path
    else
      render :new
    end
  end

  def show
    @resume = nil
    @resume = pets_user.resumes[0] if pets_user.is_a?(JobSeeker)
    authorize @job
  end

  def edit
    authorize @job
    set_company
    set_company_address
  end

  def update
    authorize @job
    set_company
    set_company_address
    if @job.update_attributes(job_params)
      flash[:info] = "#{@job.title} has been updated successfully."
      redirect_to @job
    else
      render :edit
    end
  end

  def destroy
    authorize @job
    @job.destroy
    flash[:alert] = "#{@job.title} has been deleted successfully."
    redirect_to jobs_url
  end

  def list
    raise 'Unsupported request' unless request.xhr?
    @jobs = []
    @jobs = display_jobs params[:job_type]
    render partial: 'list_jobs', locals: { jobs: @jobs, job_type: params[:job_type] }
  end

  def update_addresses
    # used to create collection_select of addresses for the company
    # (company is selected in another select list)
    raise 'Unsupported request' unless request.xhr?

    addresses = Address.where(location_type: 'Company',
                              location_id: params[:company_id])
                       .order(:state)

    render partial: 'address_select', locals: { addresses: addresses }
  end

  def apply
    unless @job = Job.find_by(id: params[:job_id])
      flash[:alert] = 'Unable to find the job the user is trying to apply to.'
      redirect_to jobs_url and return
    end
    self.action_description = 'apply. Job has either been filled or revoked'
    authorize @job

    unless @job_seeker = JobSeeker.find_by(id: params[:user_id])
      flash[:alert] = 'Unable to find the user who wants to apply.'
      redirect_to job_path(@job) and return
    end
    self.action_description = "apply for #{@job_seeker.full_name}"
    authorize @job_seeker
   
    if @job_seeker.consent && @job_seeker.job_developer == pets_user
      apply_for(@job, @job_seeker) do |job_app, job, job_seeker|
        Event.create(:JD_APPLY, job_app)
        flash[:info] = "Job is successfully applied for #{job_seeker.full_name}"
        redirect_to job_path(job) and return
      end
    end

    if pets_user == @job_seeker
      apply_for(@job, @job_seeker) do |job_app, job, job_seeker| 
        Event.create(:JS_APPLY, job_app)
        render(:apply) and return
      end
    end
  end

  def revoke
    authorize @job
    if @job.status == 'active' && @job.revoked
      flash[:alert] = "#{@job.title} is revoked successfully."
      obj = Struct.new(:job, :agency)
      Event.create(:JOB_REVOKED, obj.new(@job, Agency.first))
    else
      flash[:alert] = 'Only active job can be revoked.'
    end
    redirect_to jobs_path
  end

  def match_resume
    raise 'Unsupported request' unless request.xhr?

    job_seeker = JobSeeker.find(params[:job_seeker_id])
    resume = job_seeker.resumes[0]

    return render(json: { message: 'No résumé on file',
                          status: 404 }) unless resume

    result = ResumeCruncher.match_resume_and_job(resume.id, @job.id)

    return render(json: { message: result[:message],
                          status: 404 }) if result[:status] == 'ERROR'

    @score = result[:score]

    str = render_to_string layout: false

    render(json: { stars_html: str, status: 200 })
  end

  private

  def set_company
    if pets_user.is_a?(CompanyPerson)
      @company = [pets_user.company]
    else
      @company = Company.order(:name)
    end
  end

  def set_company_address
    case params[:action]
    when 'new', 'create'
      @address = Address.where(location_type: 'Company', 
                 location_id: pets_user.try(:company)).order(:state) || []
    when 'edit', 'update'
      @address = Address.where(location_type: 'Company', 
                 location_id: @job.company).order(:state)
    end
  end

  def apply_for(job, job_seeker, &event)
    begin
      job_application = job.job_applications.build(job_seeker_id: job_seeker.id)
      if job_application.save!
        CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                        .perform_later(Event::EVT_TYPE[:JS_APPLY],
                                       job.company,
                                       nil,
                                       application: job_application,
                                       resume_id: job_seeker.resumes[0].id)
        event.call(job_application, job, job_seeker)
      end
    # ActiveRecord::RecordInvalid is raised when validation at model level fails
    # ActiveRecord::RecordNotUnique is raised when unique index constraint on the database is violated
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      flash[:alert] = "#{job_seeker.full_name(last_name_first: false)} "\
                      'has already applied to this job.'
      redirect_to job_path(job) and return
    end
  end

  def find_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:description, :shift, :company_job_id,
                                :fulltime, :company_id, :title, :address_id,
                                :company_person_id,
                                job_skills_attributes: [:id, :_destroy, :skill_id,
                                                        :required, :min_years,
                                                        :max_years])
  end
end
