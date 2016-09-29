require 'rails_helper'

RSpec.describe SkillPolicy do

  let(:agency) { FactoryGirl.create(:agency) }
  let(:company) { FactoryGirl.create(:company) }
  let(:jd)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)  { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:company_admin) {FactoryGirl.create(:company_admin, company: company)}
  let(:company_contact) {FactoryGirl.create(:company_contact, company: company)}
  let(:skill) {FactoryGirl.create(:skill)}

  permissions :create?, :show?, :update?, :destroy? do
    it 'denies access if user not logged in' do
      expect(SkillPolicy).not_to permit(nil, skill)
    end

    it 'denies access if user is case manager' do
      expect(SkillPolicy).not_to permit(cm, skill)
    end

    it 'denies access if user is job developer' do
      expect(SkillPolicy).not_to permit(jd, skill)
    end

    it 'allows access if user is an agency admin' do
      expect(SkillPolicy).to permit(admin, skill)
    end

    it 'denies access if user is company admin' do
      expect(SkillPolicy).not_to permit(company_admin, skill)
    end

    it 'denies access if user is company contact' do
      expect(SkillPolicy).not_to permit(company_contact, skill)
    end
  end
end
