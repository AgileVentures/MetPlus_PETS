# Preview all emails at http://localhost:3000/rails/mailers/agency_mailer
class AgencyMailerPreview < ActionMailer::Preview

  def job_seeker_registered
    FactoryGirl.create(:job_seeker_status)
    job_seeker    = FactoryGirl.create(:job_seeker,
                    job_seeker_status: FactoryGirl.create(:job_seeker_status))
    agency_person = FactoryGirl.create(:agency_person)
    AgencyMailer.job_seeker_registered(agency_person,
                      job_seeker.full_name(:last_name_first => false),
                      job_seeker.id)
  end

  def company_registered
    company       = FactoryGirl.create(:company)
    agency_person = FactoryGirl.create(:agency_person)
    AgencyMailer.company_registered(agency_person,
                      company.name,
                      company.id)
  end

end
