require 'rails_helper'

RSpec.describe JobApplicationPolicy do

  let(:company) { FactoryGirl.create(:company) }
  let(:company_admin) { FactoryGirl.create(:company_admin, company: company ) }
  let(:company_contact) { FactoryGirl.create(:company_contact, company: company) }
  let(:job_seeker) { FactoryGirl.create(:job_seeker) }

  permissions :accept?, :reject?, :show? do

	it 'denies access if user is not a company admin/contact' do
	  expect(JobApplicationPolicy).not_to permit(job_seeker)
	end

	it 'allows access if user is a company admin/contact' do
	  expect(JobApplicationPolicy).to permit(company_admin)
	  expect(JobApplicationPolicy).to permit(company_contact)
	end

  end
  
end
