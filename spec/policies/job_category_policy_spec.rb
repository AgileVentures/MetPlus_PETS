require 'rails_helper'

RSpec.describe JobCategoryPolicy do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }
  let(:jd)     { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryBot.create(:case_manager, agency: agency) }
  let(:admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:company_admin) { FactoryBot.create(:company_admin, company: company) }
  let(:company_contact) { FactoryBot.create(:company_contact, company: company) }
  let(:job_category) { FactoryBot.create(:job_category) }

  permissions :create?, :show?, :update?, :destroy? do
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
