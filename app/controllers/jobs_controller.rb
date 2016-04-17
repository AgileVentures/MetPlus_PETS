class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update, :destroy]
	before_action :authentication_for_post_or_edit, only: [:new, :edit, :create, :update, :destroy] 
	before_action :is_right_company_person, only: [:edit, :destroy, :update]


	def index
		if company_p_or_job_d? && @cp_or_jd.is_a?(CompanyPerson)
			@jobs = @cp_or_jd.company.jobs.paginate(:page => params[:page],
				                                        :per_page => 32) 
		else
			@jobs = Job.paginate(:page => params[:page],
				               :per_page => 32).includes(:company)
		end
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
				if !(@cp_or_jd.address==@job.address)
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
