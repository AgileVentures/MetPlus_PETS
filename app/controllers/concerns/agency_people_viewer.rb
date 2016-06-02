module AgencyPeopleViewer
  extend ActiveSupport::Concern

  def display_agency_people people_type, per_page = 10
    case people_type
    when 'jobseeker-cm'
      return AgencyPerson.paginate(page: params[:jobseekers_cm_page],
                                    per_page: per_page).
                                    agency_people(pets_user.agency)
    end
  end

  FIELDS_IN_PEOPLE_TYPE = {
      'jobseeker-cm': [:full_name, :job_seeker_status_short_description, :last_sign_in_at]
  }

  def agency_people_fields people_type
      FIELDS_IN_PEOPLE_TYPE[people_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included m
    return unless m < ActionController::Base
    # make helper methods visible to views
    m.helper_method :application_fields
  end
end
