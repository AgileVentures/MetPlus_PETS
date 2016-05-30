module JobSeekersViewer
  extend ActiveSupport::Concern

  def display_job_applications application_type, per_page = 10, person=nil
    case application_type
    when 'my-applied'
      return JobApplication.paginate(page: params[:applications_page],
               :per_page => per_page).where(job_seeker_id: pets_user.id)
    end
  end

  FIELDS_IN_APPLICATION_TYPE = {
      'my-applied': [:title, :description, :company, :updated_at, :status]
  }

  def application_fields application_type
    FIELDS_IN_APPLICATION_TYPE[application_type.to_sym] || []
  end

  def self.included m
    return unless m < ActionController::Base
    # make helper methods visible to views
    m.helper_method :application_fields # , :any_other_helper_methods
  end
end
