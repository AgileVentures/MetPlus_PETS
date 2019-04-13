class JobSeekerEmailJob < ApplicationJob
  queue_as :default
  @available_events = {
    Event::EVT_TYPE[:JD_ASSIGNED_JS] => 'JobSeekerMailer.job_developer_assigned',
    Event::EVT_TYPE[:JD_SELF_ASSIGN_JS] => 'JobSeekerMailer.job_developer_assigned',
    Event::EVT_TYPE[:CM_ASSIGNED_JS] => 'JobSeekerMailer.case_manager_assigned',
    Event::EVT_TYPE[:CM_SELF_ASSIGN_JS] => 'JobSeekerMailer.case_manager_assigned',
    Event::EVT_TYPE[:JOB_REVOKED] => 'JobSeekerMailer.job_revoked'
  }

  def perform(evt_type, job_seeker, *args)
    if evt_type == Event::EVT_TYPE[:JD_APPLY]
      # args[0] = job_developer, args[1] = job
      JobSeekerMailer.job_applied_by_job_developer(job_seeker, args[0], args[1])
                     .deliver_later
    end
    return unless @available_events.key?(evt_type)

    send(@available_events[evt_type], email_addresses, evt_obj[0]).deliver_later
  end
end
