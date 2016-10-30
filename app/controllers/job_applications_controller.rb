# Job applications controller
class JobApplicationsController < ApplicationController
  include JobApplicationsViewer
  before_action :user_logged!
  before_action :find_application

  def accept
    if @job_application.active?
      @job_application.accept
      @job_dev = @job_application.job_seeker.job_developer
      Event.create(:APP_ACCEPTED, @job_application) if @job_dev
      flash[:info] = 'Job application accepted.'
    else
      flash[:alert] = 'Invalid action on inactive job application.'
    end
    redirect_to applications_job_url(@job_application.job)
  end

  def reject
    if @job_application.active?
      @job_application.reason_for_rejection = params[:reason_for_rejection]
      @job_application.save
      @job_application.reject
      @job_dev = @job_application.job_seeker.job_developer
      Event.create(:APP_REJECTED, @job_application) if @job_dev
      reject_success_response(request)
    else
      reject_fail_response(request)
    end
  end

  def show
  end

  def find_application
    authorize JobApplication.new
    @job_application = JobApplication.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Job Application Entry not found.'
    redirect_back_or_default
  end

private

  def reject_success_response(request)
    if request.xhr?
      render json: { message: 'Job application rejected', status: 200 }
    else
      flash[:notice] = 'Job application rejected.'
      redirect_to controller: 'jobs', action: 'applications',
                  id: @job_application.job.id unless request.xhr?
    end
  end

  def reject_fail_response(request)
    if request.xhr?
      render json: { message: 'Cannot reject an inactive job application',
                     status: 405 }
    else
      flash[:alert] = 'Cannot reject an inactive job application.'
      redirect_to applications_path(@job_application)
    end
  end
end
