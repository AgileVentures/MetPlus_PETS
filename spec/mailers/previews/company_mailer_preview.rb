# Preview all emails at http://localhost:3000/rails/mailers/company_mailer
class CompanyMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/company_mailer/pending_approval
  def pending_approval
    company        = Company.first
    company_person = CompanyPerson.first
    CompanyMailer.pending_approval(company, company_person)
  end

  def registration_approved
    company        = Company.first
    company_person = CompanyPerson.first
    CompanyMailer.registration_approved(company, company_person)
  end

  def registration_denied
    company        = Company.first
    company_person = CompanyPerson.first
    CompanyMailer.registration_denied(company, company_person,
            reason: "Your EIN is not valid and we think you're a scam operation.")
  end

  def application_received
    company = Company.last
    job_application = JobApplication.last
    CompanyMailer.application_received(company, job_application,
        "#{Rails.root}/spec/fixtures/files/Janitor-Resume.doc")
  end

end
