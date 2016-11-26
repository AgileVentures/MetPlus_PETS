module JobApplicationsViewer
  extend ActiveSupport::Concern

  def display_job_applications(application_type, id, per_page = 10)
    case application_type
    when 'job_seeker-company-person'
      JobApplication.paginate(page: params[:applications_page],
                              per_page: per_page).where(job_seeker: id)
                    .joins(:job).where('jobs.company_id = ?', pets_user.company_id)
    when 'job_seeker-default'
      JobApplication.paginate(page: params[:applications_page],
                              per_page: per_page).where(job_seeker: id)
    when 'job-job-developer'
      collection = JobApplication.where(job: id, job_seeker_id: AgencyRelation
        .where(agency_person: pets_user, agency_role_id: 1)
        .select(:job_seeker_id)).includes(:job_seeker).order(:status)
    when 'job-company-person'
      collection = JobApplication.where(job: id).includes(:job_seeker).order(:status)
    end
    return collection if collection.nil?
    collection.paginate(page: params[:applications_page], per_page: per_page)
  end

  FIELDS_IN_APPLICATION_TYPE = {
    'job_seeker-default': [:title, :description, :company, :applied_at, :status],
    'job_seeker-company-person': [:title, :applied_at, :status, :action],
    'job-job-developer': [:name, :js_status, :applied_at],
    'job-company-person': [:name, :js_status, :applied_at, :action]
  }.freeze

  def application_fields(application_type)
    FIELDS_IN_APPLICATION_TYPE[application_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included(m)
    return unless m < ActionController::Base
    m.helper_method :application_fields
  end
end
