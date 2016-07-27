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

  private

  def send_notification_mail(email_list, obj, obj_type)
    @obj      = obj
    @obj_type = obj_type
    mail to: email_list, template_name: 'agency_notification'
  end

end
