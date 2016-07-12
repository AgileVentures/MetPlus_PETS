class JobSeekerEmailJob < ActiveJob::Base
  queue_as :default

  def perform(evt_type, job_seeker, agency_person)
    case evt_type
    when Event::EVT_TYPE[:JD_ASSIGNED_JS], Event::EVT_TYPE[:JD_SELF_ASSIGN_JS]
      JobSeekerMailer.job_developer_assigned(job_seeker,
                                             agency_person).deliver_later

    when Event::EVT_TYPE[:CM_ASSIGNED_JS], Event::EVT_TYPE[:CM_SELF_ASSIGN_JS]
      JobSeekerMailer.case_manager_assigned(job_seeker,
                                            agency_person).deliver_later

    end
  end
end
