class CompanyMailerJob < ApplicationJob
  queue_as :default
  @available_events = {
    Event::EVT_TYPE[:COMP_REGISTER] => 'CompanyMailer.pending_approval',
    Event::EVT_TYPE[:COMP_APPROVED] => 'CompanyMailer.registration_approved',
    Event::EVT_TYPE[:COMP_DENIED] => 'CompanyMailer.registration_denied'
  }

  def perform(evt_type, company, company_person, options = { reason: nil,
                                                             application: nil,
                                                             resume_id: nil })
    case evt_type
    when Event::EVT_TYPE[:JS_APPLY]
      CompanyMailer
        .application_received(company, options[:application], options[:resume_id])
        .deliver_later
    when Event::EVT_TYPE[:COMP_DENIED]
      CompanyMailer.registration_denied(company, company_person, options[:reason])
                   .deliver_later
    end

    return unless @available_events.key?(evt_type)

    send(@available_events[evt_type], company, company_person).deliver_later
  end
end
