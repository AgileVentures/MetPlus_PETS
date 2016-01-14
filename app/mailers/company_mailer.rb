class CompanyMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.company_mailer.pending_approval.subject
  #
  def pending_approval(company, company_person)
    send_company_mail(company, company_person)
  end

  def registration_approved(company, company_person)
    send_company_mail(company, company_person)
  end

  def registration_denied(company, company_person, email_text)
    send_company_mail(company, company_person, email_text)
  end

  private

  def send_company_mail(company, company_person, email_text=nil)
    @company_person = company_person
    @company = company
    @agency  = company.agencies[0]
    @email_text = email_text
    mail to: company_person.email
  end
end
