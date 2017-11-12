require 'rails_helper'

RSpec.describe LicensePolicy do

  let(:agency)  { FactoryGirl.create(:agency) }
  let(:jd)      { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm)      { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:license) { FactoryGirl.create(:license) }

  permissions :create?, :show?, :update?, :destroy? do
    it 'denies access if user is case manager' do
      expect(LicensePolicy).not_to permit(cm, license)
    end

    it 'denies access if user is job developer' do
      expect(LicensePolicy).not_to permit(jd, license)
    end

    it 'allows access if user is an agency admin' do
      expect(LicensePolicy).to permit(admin, license)
    end
  end
end
