class NotifyEmailJob < ActiveJob::Base
  queue_as :default

  def perform(email_addresses, evt_type, evt_obj)
    case evt_type
    when Event::EVT_TYPE[:JS_REGISTER]
      AgencyMailer.job_seeker_registered(email_addresses, evt_obj).deliver_later

    when Event::EVT_TYPE[:COMP_REGISTER]
      AgencyMailer.company_registered(email_addresses, evt_obj).deliver_later

    when Event::EVT_TYPE[:JS_APPLY]
      AgencyMailer.job_seeker_applied(email_addresses, evt_obj).deliver_later

    when Event::EVT_TYPE[:JS_ASSIGN_JD]
      AgencyMailer.job_seeker_assigned_jd(email_addresses, evt_obj).deliver_later

    when Event::EVT_TYPE[:JS_ASSIGN_CM]
      AgencyMailer.job_seeker_assigned_cm(email_addresses, evt_obj).deliver_later

    when Event::EVT_TYPE[:JOB_POSTED]
      AgencyMailer.job_posted(email_addresses, evt_obj).deliver_later

    end
  end
end
