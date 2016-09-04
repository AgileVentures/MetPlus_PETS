class JobsController < ApplicationController

	include JobsViewer
  include JobApplicationsViewer

	before_action :find_job,	only: [:show, :edit, :update, :destroy,
                :applications, :applications_list, :revoke]
	before_action :authentication_for_post_or_edit, only: [:new, :edit, :create, :update, :destroy]
	before_action :is_right_company_person, only: [:edit, :destroy, :update]
	before_action :user_logged!, only: [:apply]

	helper_method :job_fields

	def index
		if company_p_or_job_d? && @cp_or_jd.is_a?(CompanyPerson)
			@jobs = @cp_or_jd.company.jobs.order(:title).paginate(:page => params[:page],
				                                        :per_page => 32)
		else
			@jobs = Job.order(:title).paginate(:page => params[:page],
				               :per_page => 32).includes(:company)
		end
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

		@jobs  = Job.ransack(q_params).result(distinct: true).
											includes(:company).
									 		includes(:address).
											page(params[:page]).per_page(5)
	end

	def new
		@job = Job.new(:company_id => params[:company_id],
			           :company_person_id => params[:company_person_id])
	end

	def create
		@job = Job.new(job_params)

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
	end

	def edit
	end

	def update
		if @job.update_attributes(job_params)
			flash[:info] = "#{@job.title} has been updated successfully."
			redirect_to @job
		else
			render :edit
		end
	end

	def destroy
		@job.destroy
		flash[:alert] = "#{@job.title} has been deleted successfully."
		redirect_to jobs_url
	end

  def applications
    @application_type = params[:application_type] || 'job-applied'
  end

  def applications_list
    raise 'Unsupported request' if not request.xhr?

    @application_type = params[:application_type] || 'job-applied'

    @applications = []
    @applications = display_job_applications @application_type, 5, nil, @job.id

    render partial: 'job_applications'
  end

	def list
    raise 'Unsupported request' if not request.xhr?

    @job_type = params[:job_type] || 'my-company-all'

    @jobs = []
    @jobs = display_jobs @job_type
    render partial: 'list_all', :locals => {all_jobs: @jobs, job_type: @job_type}
	end

  def update_addresses
    # used to create collection_select of addresses for the company
    # (company is selected in another select list)
    raise 'Unsupported request' if not request.xhr?

    addresses = Address.where(location_type: 'Company',
                               location_id: params[:company_id]).
                               order(:state)

    render partial: 'address_select', locals: {addresses: addresses}
  end

	def apply
		@job = Job.find_by_id params[:job_id]

		if @job == nil
			flash[:alert] = "Unable to find the job the user is trying to apply to."
			redirect_to jobs_url
			return
		end

		if @job.status != 'active'
			flash[:alert] = "Unable to apply. Job has either been filled or revoked."
			redirect_to jobs_url
			return
		end

		authorize @job

		@job_seeker = JobSeeker.find_by_id params[:user_id]
		if @job_seeker == nil
			flash[:alert] = "Unable to find the user who wants to apply."
			redirect_to job_path(@job)
			return
		end

		if pets_user == @job_seeker
			begin
				@job.apply @job_seeker
				Event.create(:JS_APPLY, @job.last_application_by_job_seeker(@job_seeker))
			rescue Exception => e
				flash[:alert] = "Unable to apply at this moment, please try again."
				redirect_to job_path(@job)
			end
		elsif pets_user == @job_seeker.job_developer
			job_app = @job.apply @job_seeker
			Event.create(:JD_APPLY, job_app)
			flash[:info] = "Job is successfully applied for #{@job_seeker.full_name}"
			redirect_to job_path(@job)
		else
			flash[:alert] = "Invalid application: You are not the Job Developer for this job seeker"
			redirect_to job_path(@job)
		end

	end

	def revoke
		if @job.status == 'active' && @job.revoked
			flash[:alert] = "#{@job.title} is revoked successfully."
			obj = Struct.new(:job, :agency)
			Event.create(:JOB_REVOKED, obj.new(@job, Agency.first))
		else
			flash[:alert] = "Only active job can be revoked."
		end
		redirect_to jobs_path
	end

	private

		def authentication_for_post_or_edit
			if !company_p_or_job_d?
			   flash[:alert] = "Sorry, You are not permitted to post, edit or delete a job!"
			   redirect_to jobs_url
			else
			   set_company_p_or_job_d
			end

		end

		def set_company_p_or_job_d
			@cp_or_jd = pets_user
		end


		def company_p_or_job_d?
			if pets_user.is_a?(CompanyPerson)
				set_company_p_or_job_d
				return true
			elsif pets_user.is_a?(AgencyPerson) && pets_user.is_job_developer?(pets_user.agency)
				set_company_p_or_job_d
				return true
			else
				return false
			end
		end

		def is_right_company_person
			if @cp_or_jd.is_a?(CompanyPerson)
				if !(@cp_or_jd.company==@job.company)
					flash[:alert] = "Sorry, you can't edit or delete #{@job.company.name} job!"
					redirect_to jobs_url
				end

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
																					:required, :min_years, :max_years])
		end


end
