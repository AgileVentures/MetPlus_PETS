class CompanyMailerJob < ApplicationJob
  queue_as :default

  def perform(evt_type, company, company_person, options = { reason: nil, application: nil,
                                                             resume_id: nil })
    case evt_type
    when Event::EVT_TYPE[:COMP_REGISTER]
      CompanyMailer.pending_approval(company, company_person).deliver_later
    when Event::EVT_TYPE[:COMP_APPROVED]
      CompanyMailer.registration_approved(company, company_person).deliver_later
    when Event::EVT_TYPE[:COMP_DENIED]
      CompanyMailer.registration_denied(company, company_person, options[:reason]).deliver_later
    when Event::EVT_TYPE[:JS_APPLY]
      CompanyMailer.application_received(company, options[:application], options[:resume_id]).deliver_later
    end
  end
end
