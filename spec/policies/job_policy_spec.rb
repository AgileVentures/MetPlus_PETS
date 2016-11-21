require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobPolicy do
  
  let(:job_seeker)  { FactoryGirl.create(:job_seeker) }
  let(:revoked_job) { FactoryGirl.create(:job, status: 'revoked') }
  let(:agency)  { FactoryGirl.create(:agency) }
  let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
  let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
  let!(:bosh_job) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
  let(:bosh_contact)      { FactoryGirl.create(:company_contact, company: bosh) }
  let(:bosh_admin)      { FactoryGirl.create(:company_admin, company: bosh) }
  let(:widget_contact) { FactoryGirl.create(:company_contact) }
  let(:widget_admin) { FactoryGirl.create(:company_admin) }

  
  let(:job_developer)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:agency_admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:case_manager)     { FactoryGirl.create(:case_manager, agency: agency) }

  
  
  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    stub_cruncher_job_update
  end

  
  
  
  
  # let!(:job_seeker) do
  #   js = FactoryGirl.create(:job_seeker)
  #   js.assign_case_manager(FactoryGirl.create(:case_manager, agency: agency), agency)
  #   js.assign_job_developer(job_developer, agency)
  #   js
  # end
    

  permissions :create?, :update?, :edit? do
    it 'only allows access if user is correct_company_person' do
      expect(JobPolicy).to permit(bosh_contact, bosh_job)
      expect(JobPolicy).to permit(bosh_admin, bosh_job)
      expect(JobPolicy).not_to permit(widget_contact, bosh_job)
      expect(JobPolicy).not_to permit(widget_admin, bosh_job)
    end

    it "only allows access if user is job_developer, agency_admin" do
      expect(JobPolicy).to permit(job_developer, bosh_job)
      expect(JobPolicy).to permit(agency_admin, bosh_job)
      expect(JobPolicy).not_to permit(case_manager, bosh_job)
    end

    it "disallows access if user is job_seeker" do
      expect(JobPolicy).not_to permit(job_seeker, bosh_job)
    end
  end

  permissions :new? do
    it 'only allows access if user is company_person' do
      expect(JobPolicy).to permit(bosh_contact, Job.new)
      expect(JobPolicy).to permit(bosh_admin, Job.new)
    end

    it "only allows access if user is job_developer, agency_admin" do
      expect(JobPolicy).to permit(job_developer, Job.new)
      expect(JobPolicy).to permit(agency_admin, Job.new)
      expect(JobPolicy).not_to permit(case_manager, Job.new)
    end

    it "disallows access if user is job_seeker" do
      expect(JobPolicy).not_to permit(job_seeker, Job.new)
    end
  end

  permissions :destroy? do
    it 'only allows access if user is correct_company_person' do
      expect(JobPolicy).to permit(bosh_contact, bosh_job)
      expect(JobPolicy).to permit(bosh_admin, bosh_job)
      expect(JobPolicy).not_to permit(widget_contact, bosh_job)
      expect(JobPolicy).not_to permit(widget_admin, bosh_job)
    end

    it "disallows access if user is agency people" do
      expect(JobPolicy).not_to permit(job_developer, bosh_job)
      expect(JobPolicy).not_to permit(agency_admin, bosh_job)
      expect(JobPolicy).not_to permit(case_manager, bosh_job)
    end

    it "disallows access if user is job_seeker" do
      expect(JobPolicy).not_to permit(job_seeker, bosh_job)
    end
  end

  permissions :show? do
    it 'only allows access if user is correct_company_person' do
      expect(JobPolicy).to permit(bosh_contact, bosh_job)
      expect(JobPolicy).to permit(bosh_admin, bosh_job)
      expect(JobPolicy).not_to permit(widget_contact, bosh_job)
      expect(JobPolicy).not_to permit(widget_admin, bosh_job)
    end

    it "only allows access if user is job_developer, agency_admin" do
      expect(JobPolicy).to permit(job_developer, bosh_job)
      expect(JobPolicy).to permit(agency_admin, bosh_job)
      expect(JobPolicy).not_to permit(case_manager, bosh_job)
    end

    it "allows access if user is visitor, job_seeker" do
      expect(JobPolicy).to permit(nil, bosh_job)
      expect(JobPolicy).to permit(job_seeker, bosh_job)
    end
  end

  permissions :apply? do
    it 'only allows access if job is active' do
      expect(JobPolicy).to permit(job_seeker, bosh_job)
      expect(JobPolicy).not_to permit(job_seeker, revoked_job)
    end

  end

  permissions :revoke? do
    it 'only allows access if user is correct_company_person' do
      expect(JobPolicy).to permit(bosh_contact, bosh_job)
      expect(JobPolicy).to permit(bosh_admin, bosh_job)
      expect(JobPolicy).not_to permit(widget_contact, bosh_job)
      expect(JobPolicy).not_to permit(widget_admin, bosh_job)
    end

    it "only allows access if user is job_developer" do
      expect(JobPolicy).to permit(job_developer, bosh_job)
      expect(JobPolicy).not_to permit(agency_admin, bosh_job)
      expect(JobPolicy).not_to permit(case_manager, bosh_job)
    end

    it "disallows access if user is visitor, job_seeker" do
      expect(JobPolicy).not_to permit(nil, bosh_job)
      expect(JobPolicy).not_to permit(job_seeker, bosh_job)
    end
  end

  # permissions :list? do
  #   it 'only allows access if user is company_person' do
  #     expect(JobPolicy).to permit(bosh_contact, bosh_job)
  #     expect(JobPolicy).to permit(bosh_admin, bosh_job)
  #     expect(JobPolicy).not_to permit(widget_contact, bosh_job)
  #     expect(JobPolicy).not_to permit(widget_admin, bosh_job)
  #   end

  #   it "disallows access if user is agency people" do
  #     expect(JobPolicy).not_to permit(job_developer, bosh_job)
  #     expect(JobPolicy).not_to permit(agency_admin, bosh_job)
  #     expect(JobPolicy).not_to permit(case_manager, bosh_job)
  #   end

  #   it "allows access if user is job_seeker" do
  #     expect(JobPolicy).  to permit(job_seeker, bosh_job)
  #   end
  # end
end
