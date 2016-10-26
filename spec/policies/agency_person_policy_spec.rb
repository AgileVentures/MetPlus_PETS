require 'rails_helper'

RSpec.describe AgencyPersonPolicy do

  let(:agency) { FactoryGirl.create(:agency) }
  let(:jd)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)  { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:cc)     { FactoryGirl.create(:company_contact) }

  permissions :update?, :edit?, :destroy? do

    it 'denies access if user is not agency admin' do
      expect(AgencyPersonPolicy).not_to permit(jd, cm)
    end
    
    it 'denies access if user is not agency admin' do
      expect(AgencyPersonPolicy).not_to permit(cc, cm)
    end
    it 'allows access if user is an agency admin' do
      expect(AgencyPersonPolicy).to permit(admin, cm)
    end
  end

  permissions :home?, :show?, :assign_job_seeker?, :list_js_cm?,
              :list_js_jd?, :list_js_without_jd?, :list_js_without_cm? do

    it 'denies access if user is not an agency person' do
      expect(AgencyPersonPolicy).not_to permit(cc, cm)
    end
    it 'allows access if user is an agency person' do
      expect(AgencyPersonPolicy).to permit(jd, cm)
    end
  end

  permissions :edit_profile?, :update_profile? do

    it 'denies access if user is not an agency person' do
      expect(AgencyPersonPolicy).not_to permit(cc, cm)
    end

    it 'denies access if user is agency person but not edit target person' do
      expect(AgencyPersonPolicy).not_to permit(jd, cm)
    end

    it 'allows access if user is agency person and is edit target person' do
      expect(AgencyPersonPolicy).to permit(jd, jd)
    end

  end
end
