class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update]

	def index
		@jobs = Job.paginate(:page => params[:page], :per_page => 20)
	end	

	def new
		@job = Job.new 
	end

	def create
		@job = Job.new(job_params)
		if @job.save 
			flash[:notice] = "The Job has been created successfully."
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
			flash[:info] = "The job has been updated job successfully."
			redirect_to @job 
		else
			render :edit 
		end
	end

	private 
		def find_job
			@job = Job.find(params[:id])
		end

		def job_params
			params.require(:job).permit(:description, :company_id, :shift, 
			  :company_person_id, :fulltime, :jobId, :job_category_id, :title)
		end


end
