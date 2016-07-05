class JobSeekerEmailJob < ActiveJob::Base
  queue_as :default

  def perform(evt_type, job_seeker, agency_person)
    case evt_type
    when Event::EVT_TYPE[:JS_ASSIGN_JD]
      JobSeekerMailer.job_developer_assigned(job_seeker,
                                             agency_person).deliver_later

    when Event::EVT_TYPE[:JS_ASSIGN_CM]
      JobSeekerMailer.case_manager_assigned(job_seeker,
                                            agency_person).deliver_later

    end
  end
end
