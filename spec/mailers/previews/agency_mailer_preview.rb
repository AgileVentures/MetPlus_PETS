# Preview all emails at http://localhost:3000/rails/mailers/agency_mailer
class AgencyMailerPreview < ActionMailer::Preview

  def job_seeker_registered
    job_seeker    = JobSeeker.first
    agency_person = AgencyPerson.first
    AgencyMailer.job_seeker_registered(agency_person.email, job_seeker)
  end

  def company_registered
    company       = Company.first
    agency_person = AgencyPerson.first
    AgencyMailer.company_registered(agency_person.email, company)
  end

  def job_seeker_applied
    job_seeker    = User.find_by_email('tom@gmail.com').actable
    agency_person = User.find_by_email('chet@metplus.org').actable
    company       = Company.find_by_email('contact@widgets.com')
    job           = company.jobs.first
    job.apply job_seeker
    application   = job.last_application_by_job_seeker(job_seeker)

    AgencyMailer.job_seeker_applied(agency_person.email, application)
  end

end
