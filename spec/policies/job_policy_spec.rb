require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobPolicy do
  subject { described_class }

  let(:visitor) { nil }
  let(:agency)  { FactoryBot.create(:agency) }
  let!(:bosh) { FactoryBot.create(:company, name: 'Bosh', agencies: [agency]) }
  let!(:bosh_mich) { FactoryBot.create(:address, location: bosh) }
  let(:bosh_job) { FactoryBot.create(:job, company: bosh, address: bosh_mich) }
  let(:revoked_job) { FactoryBot.create(:job, status: 'revoked') }
  let(:widget_job) { FactoryBot.create(:job) }

  let(:bosh_contact) { FactoryBot.create(:company_contact, company: bosh) }
  let(:bosh_admin) { FactoryBot.create(:company_admin, company: bosh) }
  let(:widget_contact) { FactoryBot.create(:company_contact) }
  let(:widget_admin) { FactoryBot.create(:company_admin) }

  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:agency_admin) { FactoryBot.create(:agency_admin, agency: agency) }
  let(:case_manager) { FactoryBot.create(:case_manager, agency: agency) }

  let(:job_seeker) { FactoryBot.create(:job_seeker) }

  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    stub_cruncher_job_update
  end

  permissions :create?, :update?, :edit?, :match_job_seekers? do
    it 'only allows access if user is correct_company_person' do
      expect(subject).to permit(bosh_contact, bosh_job)
      expect(subject).to permit(bosh_admin, bosh_job)
      expect(subject).not_to permit(widget_contact, bosh_job)
      expect(subject).not_to permit(widget_admin, bosh_job)
    end

    it 'only allows access if user is job_developer, agency_admin' do
      expect(subject).to permit(job_developer, bosh_job)
      expect(subject).to permit(agency_admin, bosh_job)
      expect(subject).not_to permit(case_manager, bosh_job)
    end

    it 'disallows access if user is job_seeker' do
      expect(subject).not_to permit(job_seeker, bosh_job)
    end
  end

  permissions :new? do
    it 'only allows access if user is company_person' do
      expect(subject).to permit(bosh_contact, Job.new)
      expect(subject).to permit(bosh_admin, Job.new)
    end

    it 'only allows access if user is job_developer, agency_admin' do
      expect(subject).to permit(job_developer, Job.new)
      expect(subject).to permit(agency_admin, Job.new)
      expect(subject).not_to permit(case_manager, Job.new)
    end

    it 'disallows access if user is job_seeker' do
      expect(subject).not_to permit(job_seeker, Job.new)
    end
  end

  permissions :destroy? do
    it 'only allows access if user is correct_company_person' do
      expect(subject).to permit(bosh_contact, bosh_job)
      expect(subject).to permit(bosh_admin, bosh_job)
      expect(subject).not_to permit(widget_contact, bosh_job)
      expect(subject).not_to permit(widget_admin, bosh_job)
    end

    it 'disallows access if user is agency people' do
      expect(subject).not_to permit(job_developer, bosh_job)
      expect(subject).not_to permit(agency_admin, bosh_job)
      expect(subject).not_to permit(case_manager, bosh_job)
    end

    it 'disallows access if user is job_seeker' do
      expect(subject).not_to permit(job_seeker, bosh_job)
    end
  end

  permissions :show? do
    it 'only allows access if user is correct_company_person' do
      expect(subject).to permit(bosh_contact, bosh_job)
      expect(subject).to permit(bosh_admin, bosh_job)
      expect(subject).not_to permit(widget_contact, bosh_job)
      expect(subject).not_to permit(widget_admin, bosh_job)
    end

    it 'only allows access if user is job_developer, agency_admin' do
      expect(subject).to permit(job_developer, bosh_job)
      expect(subject).to permit(agency_admin, bosh_job)
      expect(subject).not_to permit(case_manager, bosh_job)
    end

    it 'allows access if user is visitor, job_seeker' do
      expect(subject).to permit(nil, bosh_job)
      expect(subject).to permit(job_seeker, bosh_job)
    end
  end

  permissions :apply? do
    it 'only allows access if job is active' do
      expect(subject).to permit(job_seeker, bosh_job)
      expect(subject).not_to permit(job_seeker, revoked_job)
    end
  end

  permissions :revoke? do
    it 'only allows access if user is correct_company_person' do
      expect(subject).to permit(bosh_contact, bosh_job)
      expect(subject).to permit(bosh_admin, bosh_job)
      expect(subject).not_to permit(widget_contact, bosh_job)
      expect(subject).not_to permit(widget_admin, bosh_job)
    end

    it 'only allows access if user is job_developer' do
      expect(subject).to permit(job_developer, bosh_job)
      expect(subject).not_to permit(agency_admin, bosh_job)
      expect(subject).not_to permit(case_manager, bosh_job)
    end

    it 'disallows access if user is job_seeker' do
      expect(subject).not_to permit(job_seeker, bosh_job)
    end
  end

  permissions :match_jd_job_seekers? do
    it 'allows job developer' do
      expect(subject).to permit(job_developer, bosh_job)
    end

    it 'denies access to agency admin' do
      expect(subject).not_to permit(agency_admin, bosh_job)
    end

    it 'denies access to case manager' do
      expect(subject).not_to permit(case_manager, bosh_job)
    end

    it 'denies access to company people' do
      expect(subject).not_to permit(widget_admin, bosh_job)
      expect(subject).not_to permit(widget_contact, bosh_job)
    end

    it 'denies access to job seeker' do
      expect(subject).not_to permit(job_seeker, bosh_job)
    end

    it 'denies access to non-logged in users' do
      expect(subject).not_to permit(visitor, bosh_job)
    end
  end
  permissions :notify_job_developer? do
    it 'only allows access if user is company_person' do
      expect(JobPolicy).to permit(bosh_contact, bosh_job)
      expect(JobPolicy).to permit(bosh_admin, bosh_job)
      expect(JobPolicy).not_to permit(job_seeker, widget_job)
    end
  end
end
