class JobSeekerEmailJob < ApplicationJob
  queue_as :default

  def perform(evt_type, job_seeker, *args)
    case evt_type
    when Event::EVT_TYPE[:JD_ASSIGNED_JS], Event::EVT_TYPE[:JD_SELF_ASSIGN_JS]
      # args[0] = agency_person
      JobSeekerMailer.job_developer_assigned(job_seeker, args[0]).deliver_later

    when Event::EVT_TYPE[:CM_ASSIGNED_JS], Event::EVT_TYPE[:CM_SELF_ASSIGN_JS]
      # args[0] = agency_person
      JobSeekerMailer.case_manager_assigned(job_seeker, args[0]).deliver_later

    when Event::EVT_TYPE[:JD_APPLY]
      # args[0] = job_developer, args[1] = job
      JobSeekerMailer.job_applied_by_job_developer(job_seeker, args[0], args[1]).deliver_later

    when Event::EVT_TYPE[:JOB_REVOKED]
      JobSeekerMailer.job_revoked(job_seeker, args[0]).deliver_later
    end
  end
end
