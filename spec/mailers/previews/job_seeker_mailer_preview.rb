# Preview all emails at http://localhost:3000/rails/mailers/job_seeker_mailer
class JobSeekerMailerPreview < ActionMailer::Preview
  def job_developer_assigned
    job_seeker    = JobSeeker.first
    agency_person = AgencyPerson.first
    JobSeekerMailer.job_developer_assigned(job_seeker, agency_person)
  end

  def case_manager_assigned
    job_seeker    = JobSeeker.first
    agency_person = AgencyPerson.first
    JobSeekerMailer.case_manager_assigned(job_seeker, agency_person)
  end

  def job_applied_by_job_developer
    job_seeker    = User.find_by_email('tom@gmail.com').actable
    job_developer = User.find_by_email('chet@metplus.org').actable
    company       = Company.find_by_email('contact@widgets.com')
    job           = company.jobs.first

    JobSeekerMailer.job_applied_by_job_developer(job_seeker, job_developer, job)
  end

  def job_revoked
    job_seeker = User.find_by_email('tomseekerpets@gmail.com').actable
    job = Job.create(title: 'Sr Software Engineer',
                     company: Company.first,
                     company_job_id: 'ABC',
                     shift: Job::SHIFT_OPTIONS[0],
                     description: 'description of test job')

    job.apply(job_seeker)
    JobSeekerMailer.job_revoked(job_seeker, job)
  end
end
