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

  def application_received(company, job_application, resume_file_path)
    @job = job_application.job
    @job_seeker = job_application.job_seeker
    file_name = @job_seeker.resumes.first.file_name
    attachments[file_name] = File.read(resume_file_path)
    mail to: company.job_email, subject: 'Job Application received'
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
