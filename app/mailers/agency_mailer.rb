class AgencyMailer < ApplicationMailer

  def job_seeker_registered(agency_emails, js_name, js_id)
    send_notification_mail(agency_emails, js_name, js_id, 'Job Seeker')
  end

  def company_registered(agency_emails, company_name, company_id)
    send_notification_mail(agency_emails, company_name, company_id, 'Company')
  end

  private

  def send_notification_mail(agency_emails, obj_name, obj_id, obj_type)
    @obj_name = obj_name
    @obj_id   = obj_id
    @obj_type = obj_type
    mail to: agency_emails,
         template_name: 'agency_notification'
  end

end
