class JobSeekerMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.job_seeker_mailer.job_developer_assigned.subject
  #

  def job_developer_assigned(job_seeker, job_developer)
    send_job_seeker_mail(job_seeker, job_developer, :JD)
  end

  def case_manager_assigned(job_seeker, case_manager)
    send_job_seeker_mail(job_seeker, case_manager, :CM)
  end

  private

  def send_job_seeker_mail(job_seeker, agency_person, person_type)
    @job_seeker    = job_seeker
    @agency_person = agency_person
    @person_type   = person_type
    @agency        = agency_person.agency
    mail to: job_seeker.email, template_name: 'agency_person_assigned'
  end
end
