require 'rails_helper'

RSpec.describe AgencyPolicy do
  let(:agency) { FactoryBot.create(:agency) }
  let(:jd)     { FactoryBot.create(:job_developer, agency: agency) }
  let(:admin)  { FactoryBot.create(:agency_admin, agency: agency) }

  permissions :update?, :edit? do
    it 'denies access if user is not agency admin' do
      expect(AgencyPolicy).not_to permit(jd, agency)
    end

    it 'allows access if user is an agency admin' do
      expect(AgencyPolicy).to permit(admin, agency)
    end
  end
end
