class JobApplicationsController < ApplicationController
	include JobApplicationsViewer

	before_action :find_application

	def accept
		unless @job_application.active? 
			flash[:alert] = "Invalid action on inactive job application."
		else
			begin
				@job_application.accept
				Event.create(:APP_ACCEPTED, @job_application)
				flash[:info] = "Job application accepted."
			rescue Exception => e
				flash[:alert] = "Unable to accept at this moment, please try again."
			end
		end
		redirect_to applications_job_url(@job_application.job)
	end

	def show
	end

	def find_application
		@job_application = JobApplication.find(params[:id])
		flash[:alert] = "Job Application Entry not found." unless @job_application
	end
end