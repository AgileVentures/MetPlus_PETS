class JobSeekerMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.job_seeker_mailer.job_developer_assigned.subject
  #

  def job_developer_assigned(job_seeker, job_developer)
    send_job_seeker_mail(job_seeker: job_seeker, 
                         agency_person: job_developer, person_type: :JD, 
                         template: 'agency_person_assigned')
  end

  def case_manager_assigned(job_seeker, case_manager)
    send_job_seeker_mail(job_seeker: job_seeker, 
                         agency_person: case_manager, person_type: :CM,
                         template: 'agency_person_assigned')
  end

  def job_applied_by_job_developer(job_seeker, job_developer, job)
    send_job_seeker_mail(job_seeker: job_seeker, job_developer: job_developer, job: job)
  end

  private

  def send_job_seeker_mail(options = {})
    # user template name as stated or the previous method name
    template = options.delete(:template) || caller_locations(1,1)[0].label
    options.each { |key, value| instance_variable_set("@#{key}", value) }
    mail to: options[:job_seeker].email, template_name: template
  end
end
