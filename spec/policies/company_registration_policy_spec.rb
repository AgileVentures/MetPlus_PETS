require 'rails_helper'

describe CompanyRegistrationPolicy do

  let(:subject) { described_class }

  let(:agency)               { FactoryGirl.create(:agency) }
  let(:agency_admin)         { FactoryGirl.create(:agency_admin, agency: agency) }

  let(:agency_metplus)       { FactoryGirl.create(:agency, name: 'Metplus') }
  let(:metplus_admin)        { FactoryGirl.create(:agency_admin, agency: agency_metplus) }

  let(:company)              { FactoryGirl.create(:company, agencies: [agency]) }
  let(:company_registration) { CompanyRegistration.new(company) }
  let(:company_bayer)        { FactoryGirl.create(:company, name: 'Bayer-Raynor',
                            agencies: [agency_metplus]) }
  let(:company_admin)        { FactoryGirl.create(:company_admin, company: company) }
  let(:bayer_admin)          { FactoryGirl.create(:company_admin, company: company_bayer) }

  let(:jd) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm) { FactoryGirl.create(:case_manager, agency: agency) }
  let(:cc) { FactoryGirl.create(:company_contact) }
  let(:cp) { FactoryGirl.create(:company_person) }
  let(:js) { FactoryGirl.create(:job_seeker) }

  
  permissions :show? do
    it 'allows agency admin associated with the company' do
      expect(subject).to permit(agency_admin, company_registration)
    end

    it 'denies agency admin not associated with the company' do
      expect(subject).not_to permit(metplus_admin, company_registration)
    end

    it 'allows company admin associated with the company' do
      expect(subject).to permit(company_admin, company_registration)
    end

    it 'denies company admin not associated with the company' do
      expect(subject).not_to permit(bayer_admin, company_registration)
    end

    it 'denies access to job developer and case manager' do
      expect(subject).not_to permit(jd, company_registration)
      expect(subject).not_to permit(cm, company_registration)
    end

    it 'denies access to company contact and job seeker' do
      expect(subject).not_to permit(cc, company_registration)
      expect(subject).not_to permit(js, company_registration)
    end
  end

  permissions :update? do
    it 'allows agency admin associated with the company' do
      expect(subject).to permit(agency_admin, company_registration)
    end

    it 'denies agency admin not associated with the company' do
      expect(subject).not_to permit(metplus_admin, company_registration)
    end

    it 'denies job developer and case manager' do
      expect(subject).not_to permit(jd, company_registration)
      expect(subject).not_to permit(cm, company_registration)
    end

    it 'denies access to company person' do
      expect(subject).not_to permit(cp, company_registration)
    end

    it 'denies access to job seeker' do
      expect(subject).not_to permit(js, company_registration)
    end
  end
end