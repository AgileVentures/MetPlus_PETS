module JobSeekersViewer
  extend ActiveSupport::Concern

  def display_job_seekers people_type, agency_person, per_page = 5
    case people_type
    when 'jobseeker-cm'
      return  AgencyPerson.paginate(page: params[:jobseekers_page],
                                     per_page: per_page).
                                     job_seekers_as_case_manager(agency_person)
    
    when 'jobseeker-jd'
      return  AgencyPerson.paginate(page: params[:jobseekers_page],
                                     per_page: per_page).
                                     job_seekers_as_job_developer(agency_person)
    
    when 'jobseeker-without-jd'
      return  JobSeeker.paginate(page: params[:jobseekers_page],
                                     per_page: per_page).
                                     job_seekers_without_job_developer
    when 'jobseeker-without-cm'
      return  JobSeeker.paginate(page: params[:jobseekers_page],
                                     per_page: per_page).
                                     job_seekers_without_case_manager

    end

  end
  
  FIELDS_IN_PEOPLE_TYPE = {
       'jobseeker-cm':[:full_name, :job_seeker_status_short_description,:last_sign_in_at],

       'jobseeker-jd':[:full_name, :job_seeker_status_short_description,:last_sign_in_at],
       'jobseeker-without-jd':
[:full_name, :job_seeker_status_short_description,:last_sign_in_at],
       'jobseeker-without-cm':
[:full_name, :job_seeker_status_short_description,:last_sign_in_at]



}

  def job_seeker_fields people_type
      FIELDS_IN_PEOPLE_TYPE[people_type.to_sym] || []
  end
  
  #make helper methods visible to views
  def self.included m
    return unless m < ActionController::Base
    #make helper methods visible to views
    m.helper_method :job_seeker_fields
  end
end

