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

	def reject
		unless @job_application.active?
			if request.xhr?
				render json: {message: "Cannot reject an inactive job application",
											status: 405}
			else
				flash[:alert] = "Cannot reject an inactive job application."
				redirect_to applications_path(@job_application)
			end
		else
			@job_application.reason_for_rejection = params[:reason_for_rejection]
			@job_application.save
			@job_application.reject
			Event.create(:APP_REJECTED, @job_application) if @job_application.job_seeker.job_developer

			if request.xhr?
				render json: {message: "Job application rejected", status: 200}
			else
				flash[:notice] = "Job application rejected."
				redirect_to controller: 'jobs', action: 'applications',
										id: @job_application.job.id
			end
		end
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

end
