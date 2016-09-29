require 'rails_helper'

RSpec.describe JobCategoryPolicy do

  let(:agency) { FactoryGirl.create(:agency) }
  let(:company) { FactoryGirl.create(:company) }
  let(:jd)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)  { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:company_admin) {FactoryGirl.create(:company_admin, company: company)}
  let(:company_contact) {FactoryGirl.create(:company_contact, company: company)}
  let(:job_category) {FactoryGirl.create(:job_category)}

  permissions :create?, :show?, :update?, :destroy? do
    it 'denies access if user not logged in' do
      expect(JobCategoryPolicy).not_to permit(nil, job_category)
    end

    it 'denies access if user is case manager' do
      expect(JobCategoryPolicy).not_to permit(cm, job_category)
    end

    it 'denies access if user is job developer' do
      expect(JobCategoryPolicy).not_to permit(jd, job_category)
    end

    it 'allows access if user is an agency admin' do
      expect(JobCategoryPolicy).to permit(admin, job_category)
    end

    it 'denies access if user is company admin' do
      expect(JobCategoryPolicy).not_to permit(company_admin, job_category)
    end

    it 'denies access if user is company contact' do
      expect(JobCategoryPolicy).not_to permit(company_contact, job_category)
    end
  end
end
