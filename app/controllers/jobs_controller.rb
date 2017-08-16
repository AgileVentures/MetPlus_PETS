class JobsController < ApplicationController
  include JobsViewer
  include CruncherUtility
  include PaginationUtility

  before_action :find_job, only: [:show, :edit, :update, :destroy, :revoke,
                                  :match_resume, :match_job_seekers,
                                  :match_jd_job_seekers, :notify_job_developer]

  before_action :user_logged!, except: [:index, :list_search_jobs, :show,
                                        :match_jd_job_seekers]

  def index
    # Store, or recover, search and items-per-page criteria
    search_params, @items_count, items_per_page =
      process_pagination_params('searched_jobs')

    # Make a copy of q params since we will strip out any commas separating
    # words - need to retain any commas in the form (so user is not surprised)
    q_params = search_params ? search_params.dup : search_params

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

    #  ensure only jobs for active are returned.
    q_params = if q_params.present?
                 q_params.merge('company_status_eq' => 'active')
               else
                 { 'company_status_eq' => 'active' }
               end
    @query = Job.ransack(search_params) # For form display of entered values

    @jobs  = Job.ransack(q_params).result
                .includes(:company)
                .includes(:address)
                .page(params[:page]).per_page(items_per_page)

    render partial: 'searched_job_list' if request.xhr?
  end

  def new
    @job = Job.new
    authorize @job
    @companies = Company.order(:name)
    set_company_address
  end

  def create
    @job = Job.new(job_params)
    if pets_user.is_a?(CompanyPerson)
      @job.company_id = pets_user.company.id
      @job.company_person_id = pets_user.id
    end
    authorize @job

    if @job.save
      flash[:notice] = "#{@job.title} has been created successfully."

      obj = Struct.new(:job, :agency)
      Event.create(:JOB_POSTED, obj.new(@job, current_agency))

      redirect_to jobs_url
    else
      @companies = Company.order(:name)
      set_company_address
      render :new
    end
  end

  def show
    authorize @job
    @resume = nil
    @resume = pets_user.resumes[0] if pets_user.is_a?(JobSeeker)
    set_job_seekers
  end

  def edit
    authorize @job
    @companies = Company.order(:name)
    set_company_address
  end

  def update
    authorize @job
    if @job.update_attributes(job_params)
      flash[:info] = "#{@job.title} has been updated successfully."
      redirect_to @job
    else
      @companies = Company.order(:name)
      set_company_address
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
    @job = Job.find_by(id: params[:job_id])
    unless @job
      flash[:alert] = 'Unable to find the job the user is trying to apply to.'
      redirect_to(jobs_url) && return
    end
    self.action_description = 'apply. Job has either been filled or revoked'
    authorize @job

    @job_seeker = JobSeeker.find_by(id: params[:user_id])
    unless @job_seeker
      flash[:alert] = 'Unable to find the user who wants to apply.'
      redirect_to(job_path(@job)) && return
    end
    self.action_description = "apply for #{@job_seeker.full_name}"
    authorize @job_seeker

    if @job_seeker.consent && @job_seeker.job_developer == pets_user
      apply_for(@job_seeker) do |job_app, job, job_seeker|
        Event.create(:JD_APPLY, job_app)
        flash[:info] = "Job is successfully applied for #{job_seeker.full_name}"
        redirect_to(job_path(job)) && return
      end
    end

    if pets_user == @job_seeker
      apply_for(@job_seeker) do |job_app, _job, _job_seeker|
        Event.create(:JS_APPLY, job_app)
        render(:apply) && return
      end
    end
  end

  def revoke
    authorize @job
    if @job.active? && @job.revoked
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

    unless resume
      return render(json: { message: 'No résumé on file',
                            status: 404 })
    end

    result = ResumeCruncher.match_resume_and_job(resume.id, @job.id)

    if result[:status] == 'ERROR'
      return render(json: { message: result[:message],
                            status: 404 })
    end

    @score = result[:score]

    str = render_to_string layout: false

    render(json: { stars_html: str, status: 200 })
  end

  def match_jd_job_seekers
    authorize @job

    unless params[:job_seeker_ids]
      flash[:alert] = 'Please choose a job seeker'
      redirect_to(@job) && return
    end

    job_seeker_ids = params[:job_seeker_ids].map(&:to_i)
    match_results = get_matches(job_seeker_ids)
    @match_results = self.class.sort_by_score(match_results)
  end

  def match_job_seekers
    authorize @job
    Pusher.trigger('pusher_control',
                   'spinner_start',
                   user_id: pets_user.user.id,
                   target: '.table.table-bordered')

    # Get job match scores for all job Seekers
    result = ResumeCruncher.match_resumes(@job.id)

    Pusher.trigger('pusher_control',
                   'spinner_stop',
                   user_id: pets_user.user.id,
                   target: '.table.table-bordered')

    # If no match or match scores all too low, set flash and return
    if result.nil? || (result.delete_if { |item| item[1] <= 0.9 }).empty?
      flash[:alert] = 'No matching job seekers found.'
      redirect_to(action: 'show', id: @job.id) && return
    end

    # Create an array with each element consisting of an array:
    #  [job_seeker, job_match_score, has_applied_to_this_job]
    begin
      @job_matches = result.map do |item|
        job_seeker = Resume.find(item[0]).job_seeker
        raise "Couldn't find JobSeeker for Resume with 'id' = #{item[0]}" \
          unless job_seeker
        [job_seeker, item[1], job_seeker.applied_to_job?(@job)]
      end
    rescue RuntimeError, ActiveRecord::RecordNotFound => exc
      flash[:alert] = "Error: #{exc.message}"
      redirect_to(action: 'show', id: @job.id) && return
    end
  end

  def notify_job_developer
    # This action handles the request from a company person to notify
    # a job developer of his/her interest in a job seeker.
    # This action is invoked from the view showing all job seekers
    # that match a particular job (jobs/match_job_seekers.html.haml)

    # Parameters: {"job_developer_id"=>"3", "company_person_id"=>"1",
    #              "job_seeker_id"=>"3", "id"=>"202"}

    raise 'Unsupported request' unless request.xhr?

    authorize @job

    begin
      company_person = CompanyPerson.find(params[:company_person_id])
      job_developer  = AgencyPerson.find(params[:job_developer_id])
      job_seeker     = JobSeeker.find(params[:job_seeker_id])
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404 }
      return
    end

    # Anonymous class to contain event data
    obj = Struct.new(:job, :company_person, :job_developer, :job_seeker)

    Event.create(:CP_INTEREST_IN_JS,
                 obj.new(@job, company_person, job_developer, job_seeker))

    render json: { status: 200 }
  end

  private

  def set_job_seekers
    return unless pets_user && pets_user.is_job_developer?(current_agency)
    @job_seekers = pets_user.job_seekers
  end

  def set_company_address
    case params[:action]
    when 'new', 'create'
      @addresses = Address.where(location_type: 'Company',
                                 location_id: pets_user.try(:company)).order(:state) ||
                   []
    when 'edit', 'update'
      @addresses = Address.where(location_type: 'Company',
                                 location_id: @job.company).order(:state)
    end
  end

  def apply_for(job_seeker, &controller_response)
    @job.apply(job_seeker, &controller_response)
  # ActiveRecord::RecordInvalid is raised when validation at model level fails
  # ActiveRecord::RecordNotUnique is raised when unique index constraint
  # on the database is violated
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    flash[:alert] = "#{job_seeker.full_name(last_name_first: false)} "\
                    'has already applied to this job.'
    redirect_to(job_path(@job)) && return
  end

  def get_matches(job_seeker_ids)
    job_seeker_ids.map do |id|
      job_seeker = JobSeeker.find(id)
      resume = job_seeker.resumes[0]

      # Only make the API call if the job seeker has a resume
      result = if resume
                 ResumeCruncher.match_resume_and_job(resume.id, @job.id)
               else
                 { message: 'No résumé on file' }
               end
      result.update(job_seeker_name: job_seeker.full_name)
    end
  end

  def find_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:description, :shift, :company_job_id,
                                :fulltime, :company_id, :title, :address_id,
                                :company_person_id, :years_of_experience, job_type_ids: [],
                                job_skills_attributes: [:id, :_destroy, :skill_id, :required, :min_years, :max_years])
  end
end
