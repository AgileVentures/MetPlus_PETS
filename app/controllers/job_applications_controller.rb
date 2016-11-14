# Job applications controller
class JobApplicationsController < ApplicationController
  include JobApplicationsViewer
  before_action :user_logged!, except: :list
  before_action :find_application, except: :list

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
    @job_application = JobApplication.find(params[:id])
    authorize @job_application
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Job Application Entry not found.'
    redirect_back_or_default
  end

  def list
    raise 'Unsupported request' unless request.xhr?
    @job_applications = []
    @job_applications = display_job_applications(params[:type], 5, params[:entity_id])
    render partial: 'jobs/applied_job_list',
           locals: { job_applications: @job_applications,
                     application_type: params[:type] }
  end

  def download_resume
    job_seeker = @job_application.job_seeker

    raise 'Resume not found in DB' if job_seeker.resumes.empty?
    resume = job_seeker.resumes[0]

    resume_file = ResumeCruncher.download_resume(resume.id)
    raise 'Resume not found in Cruncher' if resume_file.nil?

    send_data resume_file.open.read, filename: resume.file_name

    rescue RuntimeError => e
      flash[:alert] = "Error: #{e}"
      redirect_back_or_default

    ensure
      if resume_file
        resume_file.close
        resume_file.unlink
      end
  end

  private

  def reject_success_response(request)
    if request.xhr?
      render json: { message: 'Job application rejected', status: 200 }
    else
      flash[:notice] = 'Job application rejected.'
      redirect_to controller: 'jobs', action: 'applications',
                  id: @job_application.job.id
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
