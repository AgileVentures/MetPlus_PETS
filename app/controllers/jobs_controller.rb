class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update, :destroy]
	before_action :authentication_for_post_or_edit, only: [:new, :edit, :create, :update] 

	def index
		if company_person?
			@jobs = @company_person.company.jobs.paginate(:page => params[:page],
				                                        :per_page => 32)
		else
			@jobs = Job.paginate(:page => params[:page],
				               :per_page => 32).includes(:company)
		end
	end	

	def new
		@job = Job.new(:company_id => params[:company_id])
	end 

	def create
		@job = Job.new(job_params)
		address = @company_person.address 
		@job.address = address 
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

		def authentication_for_post_or_edit 
			if !company_person?
			   flash[:alert] = "Sorry, You are not allowed to post or edit a job!" 
			   set_company_person 
			   redirect_to jobs_url 
			end  

		end

		def set_company_person
			@company_person = pets_user 
		end

		def company_person?
			if pets_user.is_a?(CompanyPerson)
				set_company_person
				return true
			else
				return false
			end
		end

		def find_job
			@job = Job.find(params[:id])
		end

		def job_params
			# params.require(:job).permit(:description, :company_id, :shift, 
			#   :company_person_id, :fulltime, :company_job_id, :job_category_id, :title)
			params.require(:job).permit(:description, :shift, :company_job_id,
			                            :fulltime,:company_id, :title)
		end


end
