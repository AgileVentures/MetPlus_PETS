class NotifyEmailJob < ApplicationJob
  queue_as :default
  @available_events = {
    Event::EVT_TYPE[:JS_REGISTER] => 'AgencyMailer.job_seeker_registered',
    Event::EVT_TYPE[:COMP_REGISTER] => 'AgencyMailer.company_registered',
    Event::EVT_TYPE[:JS_APPLY] => 'AgencyMailer.job_seeker_applied',
    Event::EVT_TYPE[:APP_ACCEPTED] => 'AgencyMailer.job_application_accepted',
    Event::EVT_TYPE[:APP_REJECTED] => 'AgencyMailer.job_application_rejected',
    Event::EVT_TYPE[:APP_PROCESSING] => 'AgencyMailer.job_application_processing',
    Event::EVT_TYPE[:JD_ASSIGNED_JS] => 'AgencyMailer.job_seeker_assigned_jd',
    Event::EVT_TYPE[:CM_ASSIGNED_JS] => 'AgencyMailer.job_seeker_assigned_cm',
    Event::EVT_TYPE[:JOB_POSTED] => 'AgencyMailer.job_posted',
    Event::EVT_TYPE[:JOB_REVOKED] => 'AgencyMailer.job_revoked'
  }

  def perform(email_addresses, evt_type, *evt_obj)
    if evt_type == Event::EVT_TYPE[:CP_INTEREST_IN_JS]
      # evt_obj[0] == company_person
      # evt_obj[1] == job_seeker
      # evt_obj[2] == job
      AgencyMailer.company_interest_in_job_seeker(email_addresses, evt_obj[0],
                                                  evt_obj[1],
                                                  evt_obj[2]).deliver_later
      return
    end

    send(@available_events[evt_type], email_addresses, evt_obj[0]).deliver_later
  end
end
