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
    end
  end
end
