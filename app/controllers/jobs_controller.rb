class JobsController < ApplicationController

	include JobsViewer

	before_action :find_job,	only: [:show, :edit, :update, :destroy]
	before_action :authentication_for_post_or_edit, only: [:new, :edit, :create, :update, :destroy]
	before_action :is_right_company_person, only: [:edit, :destroy, :update]
	before_action :user_logged!, only: [:apply]

	helper_method :job_fields


	def index
		if company_p_or_job_d? && @cp_or_jd.is_a?(CompanyPerson)
			@jobs = @cp_or_jd.company.jobs.paginate(:page => params[:page],
				                                        :per_page => 32)
		else
			@jobs = Job.order(:title).paginate(:page => params[:page],
				               :per_page => 32).includes(:company)
		end
	end

	def search
		debugger
		@query = Job.ransack(params[:q])
		@jobs  = @query.result.includes(:skills).includes(:company).
														 includes(:address)  if @query
	end

	def new
		@job = Job.new(:company_id => params[:company_id],
			           :company_person_id => params[:company_person_id])
	end

	def create
		@job = Job.new(job_params)

		@job.address = @cp_or_jd.address if pets_user.is_a?(CompanyPerson)
		if @job.save
			flash[:notice] = "#{@job.title} has been created successfully."
			redirect_to jobs_url
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

	def list
    raise 'Unsupported request' if not request.xhr?

    @job_type = params[:job_type] || 'my-company-all'

    @jobs = []
    @jobs = display_jobs @job_type
    render partial: 'list_all', :locals => {all_jobs: @jobs, job_type: @job_type}
	end

	def apply
		@job = Job.find_by_id params[:job_id]
		if @job == nil
			flash[:alert] = "Unable to find the job the user is trying to apply to."
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
		begin
			@job.apply @job_seeker
			Event.create(:JS_APPLY, @job.last_application_by_job_seeker(@job_seeker))
		rescue Exception => e
			flash[:alert] = "Unable to apply at this moment, please try again."
			redirect_to job_path(@job)
		end
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
			# params.require(:job).permit(:description, :company_id, :shift,
			#   :company_person_id, :fulltime, :company_job_id, :job_category_id, :title)
			params.require(:job).permit(:description, :shift, :company_job_id,
			                            :fulltime, :company_id, :title, :address_id,
			                            :company_person_id)
		end


end
