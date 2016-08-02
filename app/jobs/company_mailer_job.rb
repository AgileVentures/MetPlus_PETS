class CompanyMailerJob < ActiveJob::Base
  queue_as :default

  def perform(evt_type, company, company_person, reason = nil)
    case evt_type
      when Event::EVT_TYPE[:COMP_REGISTER]
        CompanyMailer.pending_approval(company, company_person).deliver_later
      when Event::EVT_TYPE[:COMP_APPROVED]
        CompanyMailer.registration_approved(company, company_person).deliver_later
      when Event::EVT_TYPE[:COMP_DENIED]
        CompanyMailer.registration_denied(company, company_person, reason).deliver_later
    end
  end

end
