class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update, :destroy]

	def index
		@jobs = Job.paginate(:page => params[:page], :per_page => 32)
	end	

	def new
		@job = Job.new 
	end

	def create
		@job = Job.new(job_params)
		if @job.save 
			flash[:notice] = "A job has been created successfully."
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
			flash[:info] = "The job has been updated successfully."
			redirect_to @job 
		else
			render :edit 
		end
	end

	def destroy
		@job.destroy
		flash[:alert] = "The job has been deleted successfully."
		redirect_to jobs_url 
	end

	private 
		def find_job
			@job = Job.find_by_id(params[:id])
		end

		def job_params
			params.require(:job).permit(:description, :company_id, :shift, 
			  :company_person_id, :fulltime, :jobId, :job_category_id, :title)
		end


end
