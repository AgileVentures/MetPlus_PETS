require 'rails_helper'

RSpec.describe CompanyPolicy do
  let(:agency) { FactoryBot.create(:agency) }
  let(:admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:jd)     { FactoryBot.create(:job_developer, agency: agency) }
  let(:agency2) { FactoryBot.create(:agency) }
  let(:admin2)  { FactoryBot.create(:agency_admin, agency: agency2) }
  let(:cm) { FactoryBot.create(:case_manager, agency: agency) }
  let(:company) { FactoryBot.create(:company, agencies: [agency]) }
  let(:ca)     { FactoryBot.create(:company_admin, company: company) }
  let(:cc)     { FactoryBot.create(:company_contact, company: company) }
  let(:company2) { FactoryBot.create(:company, agencies: [agency]) }
  let(:ca2)     { FactoryBot.create(:company_admin, company: company2) }
  let(:cc2)     { FactoryBot.create(:company_contact, company: company2) }
  let(:js) { FactoryBot.create(:job_seeker) }

  permissions :edit?, :update?, :show? do
    it 'denies access to job developer' do
      expect(CompanyPolicy).not_to permit(jd, company)
    end
    it 'denies access to case manager' do
      expect(CompanyPolicy).not_to permit(cm, company)
    end

    it 'denies access if agency admin but not associated with company' do
      expect(CompanyPolicy).not_to permit(admin2, company)
    end

    it 'denies access to company contact' do
      expect(CompanyPolicy).not_to permit(cc, company)
    end

    it 'denies access if company admin but another company' do
      expect(CompanyPolicy).not_to permit(ca2, company)
    end

    it 'denies access to job seeker' do
      expect(CompanyPolicy).not_to permit(js, company)
    end

    it 'allows access to agency admin when associated with company' do
      expect(CompanyPolicy).to permit(admin, company)
    end

    it 'allows access to company admin for the company' do
      expect(CompanyPolicy).to permit(ca, company)
    end
  end
  permissions :destroy? do
    it 'denies access to job developer' do
      expect(CompanyPolicy).not_to permit(jd, company)
    end
    it 'denies access to case manager' do
      expect(CompanyPolicy).not_to permit(cm, company)
    end
    it 'denies access to job seeker' do
      expect(CompanyPolicy).not_to permit(js, company)
    end
    it 'denies access to company contact' do
      expect(CompanyPolicy).not_to permit(cc, company)
    end
    it 'denies access to company admin' do
      expect(CompanyPolicy).not_to permit(ca, company)
    end
    it 'denies access if agency admin but not associated with company' do
      expect(CompanyPolicy).not_to permit(admin2, company)
    end
    it 'allows access to agency admin' do
      expect(CompanyPolicy).to permit(admin, company)
    end
  end
  permissions :list_people? do
    it 'denies access to job developer' do
      expect(CompanyPolicy).not_to permit(jd, company)
    end
    it 'denies access to case manager' do
      expect(CompanyPolicy).not_to permit(cm, company)
    end
    it 'denies access to job seeker' do
      expect(CompanyPolicy).not_to permit(js, company)
    end
    it 'denies access if agency admin but not associated with company' do
      expect(CompanyPolicy).not_to permit(admin2, company)
    end
    it 'denies access if company admin but not associated with company' do
      expect(CompanyPolicy).not_to permit(ca2, company)
    end
    it 'denies access if company contact but not associated with company' do
      expect(CompanyPolicy).not_to permit(cc2, company)
    end
    it 'allows access to agency admin' do
      expect(CompanyPolicy).to permit(admin, company)
    end
    it 'allows access to company admin' do
      expect(CompanyPolicy).to permit(ca, company)
    end
    it 'allows access to company contact' do
      expect(CompanyPolicy).to permit(cc, company)
    end
  end
end
