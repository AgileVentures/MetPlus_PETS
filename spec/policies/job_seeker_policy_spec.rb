require 'rails_helper'

RSpec.describe JobSeekerPolicy do
  
  let(:agency)  { FactoryGirl.create(:agency) }
  let(:js1)     { FactoryGirl.create(:job_seeker) }
  let(:js2)     { FactoryGirl.create(:job_seeker) } 
  let(:jd1)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:jd2)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm1)      { FactoryGirl.create(:case_manager, agency: agency) }
  let(:cm2)      { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:cc)      { FactoryGirl.create(:company_contact) }

  permissions :update?, :edit? do
    it "only allows access if user is the account owner" do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end

    it "only allows access if user is the account owner's case manager" do
      js1.assign_case_manager(cm1, agency)
      js1.assign_job_developer(jd1, agency)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).not_to permit(cm2, js1)
      expect(JobSeekerPolicy).not_to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
    end
  end

  permissions :home? do
    it 'only allows access if user is the account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end
  end

  permissions :index? do
    it "only allows access if user is agency people" do
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
    end
  end

  permissions :show?, :destroy? do
    it "only allows access if user is account owner" do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end

    it "only allow access if user is agency people" do
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
    end
  end
end
