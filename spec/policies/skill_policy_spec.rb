require 'rails_helper'

RSpec.describe SkillPolicy do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }
  let(:jd)     { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryBot.create(:case_manager, agency: agency) }
  let(:admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:company_admin) { FactoryBot.create(:company_admin, company: company) }
  let(:company_contact) { FactoryBot.create(:company_contact, company: company) }
  let(:skill) { FactoryBot.create(:skill) }

  permissions :create?, :show?, :update?, :destroy? do
    it 'denies access if user is case manager' do
      expect(SkillPolicy).not_to permit(cm, skill)
    end

    it 'denies access if user is job developer' do
      expect(SkillPolicy).not_to permit(jd, skill)
    end

    it 'allows access if user is an agency admin' do
      expect(SkillPolicy).to permit(admin, skill)
    end

    it 'allows access if user is company admin' do
      expect(SkillPolicy).to permit(company_admin, skill)
    end

    it 'allows access if user is company contact' do
      expect(SkillPolicy).to permit(company_contact, skill)
    end
  end
end
