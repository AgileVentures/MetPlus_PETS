module JobApplicationsViewer
  extend ActiveSupport::Concern

  def display_job_applications application_type, per_page=10, id

    case application_type
    when 'job_seeker'
      return JobApplication.paginate(page: params[:applications_page], 
        :per_page => per_page).where(job_seeker: id) 
    when 'job-applied'
      return JobApplication.paginate(page: params[:applications_page],
               :per_page => per_page).where(job: id).
               includes(:job_seeker).order(:status)
    end
  end

  FIELDS_IN_APPLICATION_TYPE = {
      'job_seeker': [:title, :description, :company, :applied_at, :status],
      'job-applied': [:name, :js_status, :applied_at, :action]
  }

  def application_fields application_type
    FIELDS_IN_APPLICATION_TYPE[application_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included m
    return unless m < ActionController::Base
    m.helper_method :application_fields
  end
end
