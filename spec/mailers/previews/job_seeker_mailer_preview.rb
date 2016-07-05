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

end
