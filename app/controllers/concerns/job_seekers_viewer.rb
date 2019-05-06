module JobSeekersViewer
  extend ActiveSupport::Concern

  def display_job_seekers(people_type, agency_person, per_page = 5)
    collection = nil
    case people_type
    when 'jobseeker-cm'

      collection = agency_person.job_seekers_as_case_manager
    when 'jobseeker-jd'

      collection = agency_person.job_seekers_as_job_developer

    when 'jobseeker-without-jd'

      collection = JobSeeker.job_seekers_without_job_developer

    when 'jobseeker-without-cm'

      collection = JobSeeker.job_seekers_without_case_manager

    end

    return collection if collection.nil?

    collection.paginate(page: params[:jobseekers_page], per_page: per_page)
  end

  FIELDS_IN_PEOPLE_TYPE = {
    'jobseeker-cm': %i[full_name job_seeker_status_short_description
                       last_sign_in_at match_rating],

    'jobseeker-jd': %i[full_name job_seeker_status_short_description
                       last_sign_in_at match_rating],
    'jobseeker-without-jd': %i[full_name job_seeker_status_short_description
                               last_sign_in_at],
    'jobseeker-without-cm': %i[full_name job_seeker_status_short_description
                               last_sign_in_at]

  }.freeze

  def job_seeker_fields(people_type)
    FIELDS_IN_PEOPLE_TYPE[people_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included(mod)
    return unless mod < ActionController::Base

    # make helper methods visible to views
    mod.helper_method :job_seeker_fields
  end
end
