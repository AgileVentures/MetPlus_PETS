require 'webmock'
include WebMock::API
require './spec/support/service_stub_helpers'
include ServiceStubHelpers::Cruncher
# Preview all emails at http://localhost:3000/rails/mailers/company_mailer
class CompanyMailerPreview < ActionMailer::Preview
  # Preview this email
  # at http://localhost:3000/rails/mailers/company_mailer/pending_approval
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
    CompanyMailer.registration_denied(
      company, company_person,
      reason: "Your EIN is not valid and we think you're a scam operation."
    )
  end

  def application_received
    WebMock.enable!
    stub_cruncher_authenticate
    stub_cruncher_file_download('./spec/fixtures/files/Janitor-Resume.doc')

    job_application = nil
    JobApplication.includes(:job_seeker, :application_questions, :job).each do |ja|
      next if ja.job_seeker.resumes.empty?

      job_application = ja
      break
    end

    raise 'Cannot find application with resume' unless job_application

    job_application.application_questions = []

    job_application.application_questions <<
      [ApplicationQuestion.create(job_application: job_application,
                                  question: Question.find(1),
                                  answer: true),
       ApplicationQuestion.create(job_application: job_application,
                                  question: Question.find(2),
                                  answer: false)]

    CompanyMailer.application_received(job_application.job.company,
                                       job_application,
                                       job_application.job_seeker.resumes[0].id)
  end
end
