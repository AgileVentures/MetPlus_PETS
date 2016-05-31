module JobApplicationsViewer
  extend ActiveSupport::Concern

  def display_job_applications application_type, per_page=10, js_id=nil
    case application_type
    when 'my-applied'
      return JobApplication.paginate(page: params[:applications_page],
               :per_page => per_page).where(job_seeker_id: pets_user.id)
    when 'js-applied'
      return JobApplication.paginate(page: params[:applications_page],
               :per_page => per_page).where(job_seeker_id: js_id)
    end
  end

  FIELDS_IN_APPLICATION_TYPE = {
      'my-applied': [:title, :description, :company, :updated_at, :status],
      'js-applied': [:title, :description, :company, :updated_at, :status]
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
