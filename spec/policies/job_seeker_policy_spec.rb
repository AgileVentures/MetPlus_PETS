require 'rails_helper'

RSpec.describe JobSeekerPolicy do
  let(:visitor) { nil }
  let(:agency)  { FactoryGirl.create(:agency) }
  let(:js1)     { FactoryGirl.create(:job_seeker) }
  let(:js2)     { FactoryGirl.create(:job_seeker) }
  let(:jd1)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:jd2)     { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm1)     { FactoryGirl.create(:case_manager, agency: agency) }
  let(:cm2)     { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let!(:cc)     { FactoryGirl.create(:company_contact, company: comp) }
  let(:cc2)     { FactoryGirl.create(:company_contact) }
  let(:comp)    { FactoryGirl.create(:company) }
  let(:job)     { FactoryGirl.create(:job, company: comp) }
  let!(:ja) do
    FactoryGirl.create(:job_application, job: job, job_seeker: js1)
  end
  let!(:ca)     { FactoryGirl.create(:company_admin, company: comp) }
  let(:comp2)   { FactoryGirl.create(:company) }
  let(:job2)    { FactoryGirl.create(:job, company: comp2) }
  let(:ca2)     { FactoryGirl.create(:company_admin, company: comp2) }
  permissions :update?, :edit? do
    it 'only allows access if user is the account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end

    it "only allows access if user is account owner's case manager or job_developer" do
      js1.assign_case_manager(cm1, agency)
      js1.assign_job_developer(jd1, agency)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cm2, js1)
      expect(JobSeekerPolicy).not_to permit(jd2, js1)
      expect(JobSeekerPolicy).not_to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
    end
  end

  permissions :create?, :new? do
    it 'only allows access if user is visitor' do
      expect(JobSeekerPolicy).to permit(visitor, JobSeeker.new)
    end

    it 'only allows access if user is agency people' do
      expect(JobSeekerPolicy).to permit(jd1, JobSeeker.new)
      expect(JobSeekerPolicy).to permit(cm1, JobSeeker.new)
      expect(JobSeekerPolicy).to permit(admin, JobSeeker.new)
      expect(JobSeekerPolicy).not_to permit(cc, JobSeeker.new)
      expect(JobSeekerPolicy).not_to permit(ca, JobSeeker.new)
      expect(JobSeekerPolicy).not_to permit(js1, JobSeeker.new)
    end
  end

  permissions :home? do
    it 'only allows access if user is the account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end
  end

  permissions :index? do
    it 'only allows access if user is agency people' do
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
    end
  end

  permissions :show? do
    it 'only allows access if user is account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end

    it 'only allow access if user is agency people' do
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).to permit(cm1, js1)
      expect(JobSeekerPolicy).to permit(admin, js1)
    end

    it 'only allow access if user is company people' do
      expect(JobSeekerPolicy).to permit(cc, js1)
      expect(JobSeekerPolicy).to permit(ca, js1)
    end
  end

  permissions :preview_info? do
    it "only allows access if user is the account owner's job developer" do
      js1.assign_case_manager(cm1, agency)
      js1.assign_job_developer(jd1, agency)
      expect(JobSeekerPolicy).to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cm1, js1)
      expect(JobSeekerPolicy).not_to permit(jd2, js1)
      expect(JobSeekerPolicy).not_to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
    end
  end

  permissions :destroy? do
    it 'only allows access if user is account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end

    it 'only allows access if user is agency admin' do
      expect(JobSeekerPolicy).to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cm1, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
    end
  end

  permissions :allow? do
    it 'only allows access if user is visitor' do
      expect(JobSeekerPolicy).to permit(visitor, JobSeeker.new)
    end

    it 'only allows access if user is account owner' do
      js1.assign_case_manager(cm1, agency)
      js1.assign_job_developer(jd1, agency)
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
      expect(JobSeekerPolicy).not_to permit(cm1, js1)
      expect(JobSeekerPolicy).not_to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
      expect(JobSeekerPolicy).not_to permit(cc, js1)
    end
  end

  permissions :apply? do
    it 'disallows access if user is company_person' do
      expect(JobSeekerPolicy).not_to permit(cc, js1)
      expect(JobSeekerPolicy).not_to permit(ca, js1)
    end

    it "only allows access if user is job_seeker's job_developer" do
      js1.assign_job_developer(jd1, agency)
      expect(JobSeekerPolicy).to permit(jd1, js1)
      js1.consent = false
      expect(JobSeekerPolicy).not_to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cm1, js1)
      expect(JobSeekerPolicy).not_to permit(jd2, js1)
    end

    it 'allows access if user is account owner' do
      expect(JobSeekerPolicy).to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(js2, js1)
    end
  end
  permissions :download_resume? do
    it 'allows access if user is a company admin/contact' do
      expect(JobSeekerPolicy).to permit(ca, js1)
      expect(JobSeekerPolicy).to permit(cc, js1)
    end

    it 'denies access if user is not a company admin/contact' do
      expect(JobSeekerPolicy).not_to permit(js1, js1)
      expect(JobSeekerPolicy).not_to permit(admin, js1)
      expect(JobSeekerPolicy).not_to permit(jd1, js1)
      expect(JobSeekerPolicy).not_to permit(cm1, js1)
    end

    it 'denies company people of the wrong company' do
      expect(JobSeekerPolicy).not_to permit(ca2,
                                            js1)
      expect(JobSeekerPolicy).not_to permit(cc2,
                                            js1)
    end
  end
end
