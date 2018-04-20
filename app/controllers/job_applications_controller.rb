# Job applications controller
class JobApplicationsController < ApplicationController
  include JobApplicationsViewer
  before_action :user_logged!, except: :list
  before_action :find_application, except: :list

  def accept
    begin
      JobApplications::Hire.new.call(@job_application)
      flash[:info] = 'Job application accepted.'
    rescue JobApplications::JobNotActive
      flash[:alert] = 'Invalid action on inactive job application.'
    end
    redirect_to job_url(@job_application.job)
  end

  def reject
    JobApplications::Reject.new.call(@job_application, params[:reason_for_rejection])
    reject_success_response(request)
  rescue JobApplications::JobNotActive
    reject_fail_response(request)
  end

  def process_application
    begin
      JobApplications::Processing.new.call(@job_application, current_user)
      flash[:info] = 'Job application processing.'
    rescue JobApplications::JobNotActive
      flash[:alert] = 'Invalid action on inactive job application.'
    end
    redirect_to job_url(@job_application.job)
  end

  def show; end

  def list
    raise 'Unsupported request' unless request.xhr?
    @job_applications = []
    @job_applications = display_job_applications(params[:type], params[:entity_id], 5)
    render partial: 'jobs/applied_job_list',
           locals: { job_applications: @job_applications,
                     application_type: params[:type] }
  end

  private

  def find_application
    @job_application = JobApplication.find(params[:id])
    authorize @job_application
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Job Application Entry not found.'
    redirect_back_or_default
  end

  def reject_success_response(request)
    if request.xhr?
      render json: { message: 'Job application rejected', status: 200 }
    else
      flash[:notice] = 'Job application rejected.'
      redirect_to job_url(@job_application.job)
    end
  end

  def reject_fail_response(request)
    if request.xhr?
      render json: { message: 'Cannot reject an inactive job application',
                     status: 405 }
    else
      flash[:alert] = 'Cannot reject an inactive job application.'
      redirect_to application_path(@job_application)
    end
  end
end
