class AgencyMailer < ApplicationMailer

  def job_seeker_registered(agency_person, js_name, js_id)
    send_notification_mail(agency_person, js_name, js_id, 'Job Seeker')
  end

  def company_registered(agency_person, company_name, company_id)
    send_notification_mail(agency_person, company_name, company_id, 'Company')
  end

  private

  def send_notification_mail(agency_person, obj_name, obj_id, obj_type)
    @agency_person = agency_person
    @obj_name = obj_name
    @obj_id   = obj_id
    @obj_type = obj_type
    mail to: agency_person.email,
         template_name: 'agency_notification'
  end

end
