class CompanyMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.company_mailer.pending_approval.subject
  #
  def pending_approval(company, company_person)
    send_company_mail(company, company_person)
  end

  def registration_approved(company, company_person)
    send_company_mail(company, company_person)
  end

  def registration_denied(company, company_person, email_text)
    send_company_mail(company, company_person, email_text)
  end

  def application_received(company, job_application, resume_id)
    @job = job_application.job
    @job_seeker = job_application.job_seeker

    # Download the resume from Cruncher
    resume_temp_file = ResumeCruncher.download_resume(resume_id)
    file_name = @job_seeker.resumes.first.file_name
    attachments[file_name] = File.read(resume_temp_file.path)

    mail(to: company.job_email, from: ENV['ADMIN_EMAIL'],
         subject: 'Job Application received')

    # On windows, unlinking a file before closing fails
    # For more, see http://docs.cs.up.ac.za/programming/ruby/ruby_2_2_0_stdlib/libdoc/tempfile/rdoc/Tempfile.html#method-i-unlink-label-Unlink-before-close
    resume_temp_file.close(unlink_now=true)
  end

  private

  def send_company_mail(company, company_person, email_text=nil)
    @company_person = company_person
    @company = company
    @agency  = company.agencies[0]
    @email_text = email_text
    mail(to: company_person.email, from: ENV['ADMIN_EMAIL'])
  end
end
