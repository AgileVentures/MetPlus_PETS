class JobApplicationsController < ApplicationController
	include JobApplicationsViewer

	before_action :find_application

	def accept
		unless @job_application.active? 
			flash[:alert] = "Invalid action on inactive job application."
		else
			@job_application.accept
			Event.create(:APP_ACCEPTED, @job_application) if @job_application.job_seeker.job_developer
			flash[:info] = "Job application accepted."
		end
		redirect_to applications_job_url(@job_application.job)
	end

	def show
	end

	def find_application
		begin
			@job_application = JobApplication.find(params[:id])
		rescue
			flash[:alert] = "Job Application Entry not found."
			redirect_back_or_default
		end
	end

	def redirect_back_or_default(default = root_path)
    redirect_to (request.referer.present? ? :back : default)
  end
  
end