require 'rails_helper'

RSpec.describe BranchPolicy do

  let(:agency)  { FactoryGirl.create(:agency)}
  let(:agency1) { FactoryGirl.create(:agency)}
  let(:company) { FactoryGirl.create(:company, agencies: [agency])}
  let(:branch)  { FactoryGirl.create(:branch, agency: agency)}
  let(:jd)      { FactoryGirl.create(:job_developer, agency: agency)}
  let(:cm)      { FactoryGirl.create(:case_manager, agency: agency)}
  let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency)}
  let(:jd1)     { FactoryGirl.create(:job_developer, agency: agency1)}
  let(:cm1)     { FactoryGirl.create(:case_manager, agency: agency1)}
  let(:admin1)  { FactoryGirl.create(:agency_admin, agency: agency1)}
  let(:company_admin)   { FactoryGirl.create(:company_admin, company: company)}
  let(:company_contact) { FactoryGirl.create(:company_contact, company: company)}
  let(:js) { FactoryGirl.create(:job_seeker)}
 
  permissions :new?, :create?, :edit?, :update?, :destroy? do
    it "denies access if user is job developer" do
      expect(BranchPolicy).not_to permit(jd, branch)
    end
    it "denies access if user is case manager" do
      expect(BranchPolicy).not_to permit(cm, branch)
    end
    it "allows access if user is an agency admin" do    
      expect(BranchPolicy).to permit(admin, branch)
    end
    it "denies access if user is an another agency job developer" do
      expect(BranchPolicy).not_to permit(jd1, branch)
    end
    it "denies access if user is an another agency case manager" do
      expect(BranchPolicy).not_to permit(cm1, branch)
    end
    it "denies access if user is an another agency admin" do
      expect(BranchPolicy).not_to permit(admin1, branch)
    end
    it "denies access if user is company admin" do
      expect(BranchPolicy).not_to permit(company_admin, branch)
    end
    it "denies access if user is company contact" do
      expect(BranchPolicy).not_to permit(company_contact, branch)
    end
    it "denies access if user is jobseeker" do
      expect(BranchPolicy).not_to permit(js, branch)
    end
  end
  permissions :show?  do
    it "allows access if user is an agency person" do
      expect(BranchPolicy).to permit(admin, branch)
      expect(BranchPolicy).to permit(jd, branch)
      expect(BranchPolicy).to permit(cm, branch)
    end
    it "denies access if user is another agency person" do
      expect(BranchPolicy).not_to permit(admin1, branch)
      expect(BranchPolicy).not_to permit(jd1, branch)
      expect(BranchPolicy).not_to permit(cm1, branch)
    end
    it "denies access if user is company admin" do
      expect(BranchPolicy).not_to permit(company_admin, branch)
    end
    it "denies access if user is company contact" do
      expect(BranchPolicy).not_to permit(company_contact, branch)
    end
    it "denies access if user is jobseeker" do
      expect(BranchPolicy).not_to permit(js, branch)
    end
  end
end
