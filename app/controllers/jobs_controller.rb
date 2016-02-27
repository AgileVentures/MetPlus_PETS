class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update, :destroy]

	def index
		# @jobs = Job.paginate(:page => params[:page], :per_page => 32).includes(:company)
		@jobs = Job.paginate(:page => params[:page], :per_page => 32)
	end	

	def new
		@job = Job.new
	end

	def create
		@job = Job.new(job_params)
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

	private 
		def find_job
			@job = Job.find(params[:id])
		end

		def job_params
			# params.require(:job).permit(:description, :company_id, :shift, 
			#   :company_person_id, :fulltime, :company_job_id, :job_category_id, :title)
			params.require(:job).permit(:description, :shift, :fulltime, :company_job_id, :title)
		end


end
