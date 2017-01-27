require 'rails_helper'

RSpec.describe JobApplicationPolicy do
  let(:company) { FactoryGirl.create(:company) }
  let(:company2) { FactoryGirl.create(:company) }
  let(:company_admin1) { FactoryGirl.create(:company_admin, company: company) }
  let(:company_admin2) { FactoryGirl.create(:company_admin, company: company2) }
  let(:company_contact) do
    FactoryGirl.create(:company_contact,
                       company: company)
  end
  let(:company_contact2) do
    FactoryGirl.create(:company_contact,
                       company: company2)
  end

  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  let(:job_seeker) { FactoryGirl.create(:job_seeker) }
  let(:job) { FactoryGirl.create(:job, company: company) }
  let(:job_application) do
    FactoryGirl.create(:job_application, job: job,
                                         job_seeker: job_seeker)
  end
  let(:agency) { FactoryGirl.create(:agency) }
  let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager) { FactoryGirl.create(:case_manager, agency: agency) }

  permissions :accept?, :reject?, :show? do
    it 'allows access if user is a company admin/contact' do
      expect(JobApplicationPolicy).to permit(company_admin1, job_application)
      expect(JobApplicationPolicy).to permit(company_contact, job_application)
    end

    it 'denies access if user is not a company admin/contact' do
      expect(JobApplicationPolicy).not_to permit(job_seeker, job_application)
      expect(JobApplicationPolicy).not_to permit(agency_admin, job_application)
      expect(JobApplicationPolicy).not_to permit(job_developer, job_application)
      expect(JobApplicationPolicy).not_to permit(case_manager, job_application)
    end

    it 'denies company people of the wrong company' do
      expect(JobApplicationPolicy).not_to permit(company_admin2,
                                                 job_application)
      expect(JobApplicationPolicy).not_to permit(company_contact2,
                                                 job_application)
    end
  end
end
