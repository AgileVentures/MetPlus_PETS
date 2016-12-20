class AgencyMailer < ApplicationMailer
  def job_seeker_registered(email_list, job_seeker)
    send_notification_mail(email_list, job_seeker, 'Job Seeker')
  end

  def company_registered(email_list, company)
    send_notification_mail(email_list, company, 'Company')
  end

  def job_seeker_applied(email_list, job_application)
    send_notification_mail(email_list, job_application, 'Job Application')
  end

  def job_application_accepted(email_list, job_application)
    send_notification_mail(email_list, job_application, 'Job Application Accepted')
  end

  def job_application_rejected(email_list, job_application)
    send_notification_mail(email_list, job_application, 'Job Application Rejected')
  end

  def job_seeker_assigned_jd(email_list, job_seeker)
    send_notification_mail(email_list, job_seeker, 'Job Seeker Assigned JD')
  end

  def job_seeker_assigned_cm(email_list, job_seeker)
    send_notification_mail(email_list, job_seeker, 'Job Seeker Assigned CM')
  end

  def job_posted(email_list, job)
    send_notification_mail(email_list, job, 'New Job Posted')
  end

  def job_revoked(email_list, job)
    send_notification_mail(email_list, job, 'Job Revoked')
  end

  def job_applied_by_other_job_developer(job_seeker, primary_job_developer,
                                         job_developer, job)
    @primary_job_developer = primary_job_developer
    @job_developer = job_developer
    @job = job
    @job_seeker = job_seeker
    send_notification_mail(primary_job_developer.email, nil, nil,
                           'job_applied_by_job_developer')
  end

  def company_interest_in_job_seeker(email_list, company_person, job_seeker, job)
    @company_person = company_person
    @job_seeker     = job_seeker
    @job = job
    send_notification_mail(email_list, nil, 'Company interest in JS')
  end

  private

  def send_notification_mail(email_list, obj, obj_type,
                             template = 'agency_notification')
    @obj      = obj
    @obj_type = obj_type
    mail(to: email_list, from: ENV['ADMIN_EMAIL'], template_name: template)
  end
end
