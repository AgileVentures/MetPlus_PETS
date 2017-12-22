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
    job_seeker    = JobSeeker.first
    agency_person = job_seeker.agency_people.first
    application   = job_seeker.job_applications.first

    AgencyMailer.job_seeker_applied(agency_person.email, application)
  end

  def job_application_accepted
    job_seeker    = JobSeeker.first
    agency_person = job_seeker.agency_people.first
    application   = job_seeker.job_applications.first

    AgencyMailer.job_application_accepted(agency_person.email, application)
  end

  def job_application_rejected
    job_seeker    = JobSeeker.first
    agency_person = job_seeker.agency_people.first
    application   = job_seeker.job_applications.first

    AgencyMailer.job_application_rejected(agency_person.email, application)
  end

  def job_seeker_assigned_jd
    job_seeker    = JobSeeker.first
    agency_person = AgencyPerson.first
    AgencyMailer.job_seeker_assigned_jd(agency_person.email, job_seeker)
  end

  def job_seeker_assigned_cm
    job_seeker    = JobSeeker.first
    agency_person = AgencyPerson.first
    AgencyMailer.job_seeker_assigned_cm(agency_person.email, job_seeker)
  end

  def job_posted
    stub_cruncher_calls
    job = Job.create(title: 'Software Engineer',
                     company: Company.first,
                     company_job_id: 'XYZ',
                     description: 'description of test job')
    job_developer = User.find_by_email('chet@metplus.org').actable

    AgencyMailer.job_posted(job_developer.email, job)
  end

  def job_revoked
    stub_cruncher_calls
    job = Job.create(title: 'Software Engineer',
                     company: Company.first,
                     company_job_id: 'XYZ',
                     description: 'description of test job')
    job_developer = User.find_by_email('chet@metplus.org').actable

    AgencyMailer.job_revoked(job_developer.email, job)
  end

  def stub_cruncher_calls
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end
end
