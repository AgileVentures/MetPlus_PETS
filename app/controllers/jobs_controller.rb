class JobsController < ApplicationController
  include JobsViewer

  before_action :find_job, only: [:show, :edit, :update, :destroy, :revoke,
                                  :match_resume, :match_job_seekers]
  before_action :user_logged!, except: [:index, :list_search_jobs, :show]

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
    @companies = Company.order(:name)
    set_company_address
  end

  def create
    @companies = Company.order(:name)
    set_company_address
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

      redirect_to jobs_path
    else
      render :new
    end
  end

  def show
    authorize @job
    @resume = nil
    @resume = pets_user.resumes[0] if pets_user.is_a?(JobSeeker)
  end

  def edit
    authorize @job
    @companies = Company.order(:name)
    set_company_address
  end

  def update
    authorize @job
    @companies = Company.order(:name)
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
      redirect_to(jobs_url) && return
    end
    self.action_description = 'apply. Job has either been filled or revoked'
    authorize @job

    unless @job_seeker = JobSeeker.find_by(id: params[:user_id])
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

    return render(json: { message: 'No résumé on file',
                          status: 404 }) unless resume

    result = ResumeCruncher.match_resume_and_job(resume.id, @job.id)

    return render(json: { message: result[:message],
                          status: 404 }) if result[:status] == 'ERROR'

    @score = result[:score]

    str = render_to_string layout: false

    render(json: { stars_html: str, status: 200 })
  end

  def match_job_seekers
    authorize @job
    Pusher.trigger('pusher_control',
                   'spinner_start',
                   user_id: pets_user.user.id,
                   target: '.table.table-bordered')

    # Get job match scores for all job Seekers
    if Rails.env.development?
      result = ResumeCruncher.match_resumes(1)
    else
      result = ResumeCruncher.match_resumes(@job.id)
    end

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
      @job_matches = result.collect do |item|
        job_seeker = Resume.find(item[0]).job_seeker
        raise "Couldn't find JobSeeker for Resume with 'id' = #{item[0]}" \
          unless job_seeker
        [job_seeker, item[1], job_seeker.applied_to_job?(@job)]
      end
    rescue Exception => exc
      flash[:alert] = "Error: #{exc.message}"
      redirect_to(action: 'show', id: @job.id) && return
    end
  end

  private

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
