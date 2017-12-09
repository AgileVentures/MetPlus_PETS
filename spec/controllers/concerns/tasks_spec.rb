require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestTasksConcernClass < ApplicationController
  include Tasks
end

RSpec.describe TestTasksConcernClass do
  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  let!(:agency)       { FactoryBot.create(:agency) }
  let(:agency_admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:company)       { FactoryBot.create(:company, agencies: [agency]) }
  let(:company_admin) { FactoryBot.create(:company_admin, company: company) }
  let(:cmpy_person)   { FactoryBot.create(:company_contact, company: company) }
  let(:job_seeker1)   { FactoryBot.create(:job_seeker) }
  let(:job_seeker2)   { FactoryBot.create(:job_seeker) }
  let(:job_seeker3)   { FactoryBot.create(:job_seeker) }
  let(:job)           { FactoryBot.create(:job, company: company) }

  let!(:task_js_unassigned1) { Task.new_js_unassigned_jd_task(job_seeker1, agency) }
  let!(:task_js_unassigned2) { Task.new_js_unassigned_jd_task(job_seeker2, agency) }
  let!(:task_company_reg) do
    Task.new_review_company_registration_task(company, agency)
  end
  let!(:task_cmpy_interest) do
    Task.new_company_interest_task(job_seeker2, company, job, agency)
  end
  let!(:task_review_jobapp1)  { Task.new_review_job_application_task(job, company) }
  let!(:task_review_jobapp2)  { Task.new_review_job_application_task(job, company) }

  describe 'Agency Admin' do
    before(:each) do
      allow(subject).to receive(:pets_user).and_return(agency_admin)
      allow(subject).to receive(:params[0]).and_return('test')
    end
    it 'gets new agency tasks' do
      # status == new
      expect(subject.display_tasks('agency-new'))
        .to match_array [task_js_unassigned1, task_js_unassigned2,
                         task_company_reg, task_cmpy_interest]
    end
    it 'gets all agency tasks' do
      # status != done and status != new
      task_js_unassigned2.assign job_developer
      expect(subject.display_tasks('agency-all')).to match_array [task_js_unassigned2]
    end
    it 'gets all closed agency tasks' do
      # status == done
      task_js_unassigned1.assign job_developer
      task_js_unassigned1.work_in_progress
      task_js_unassigned1.complete
      expect(subject.display_tasks('agency-closed')).to match_array [task_js_unassigned1]
    end
  end

  describe 'Company Admin' do
    before(:each) do
      allow(subject).to receive(:pets_user).and_return(company_admin)
      allow(subject).to receive(:params[0]).and_return('test')
    end
    it 'gets all open company tasks' do
      # status != done
      expect(subject.display_tasks('company-open'))
        .to match_array [task_review_jobapp1, task_review_jobapp2]
    end
    it 'gets all new company tasks' do
      # status == new
      task_review_jobapp1.assign cmpy_person
      expect(subject.display_tasks('company-open'))
        .to match_array [task_review_jobapp2]
    end
    it 'gets all company tasks' do
      # status != done and status != new
      task_review_jobapp2.assign cmpy_person
      expect(subject.display_tasks('company-open'))
        .to match_array [task_review_jobapp1]
    end
    it 'gets all closed company tasks' do
      # status == done
      task_review_jobapp2.assign cmpy_person
      task_review_jobapp2.work_in_progress
      task_review_jobapp2.complete
      expect(subject.display_tasks('company-closed'))
        .to match_array [task_review_jobapp2]
    end
  end

  describe 'Agency Person' do
    before(:each) do
      allow(subject).to receive(:pets_user).and_return(job_developer)
      allow(subject).to receive(:params[0]).and_return('test')
    end
    it 'gets my open tasks' do
      # status != done
      task_js_unassigned1.assign job_developer
      task_js_unassigned2.assign job_developer
      expect(subject.display_tasks('mine-open'))
        .to match_array [task_js_unassigned1, task_js_unassigned2]
    end
    it 'gets my closed tasks' do
      # status == done
      task_js_unassigned1.assign job_developer
      task_js_unassigned1.work_in_progress
      task_js_unassigned1.complete
      expect(subject.display_tasks('mine-closed'))
        .to match_array [task_js_unassigned1]
    end
  end

  describe 'Company Person' do
    before(:each) do
      allow(subject).to receive(:pets_user).and_return(cmpy_person)
      allow(subject).to receive(:params[0]).and_return('test')
    end
    it 'gets my open tasks' do
      # status != done
      task_company_reg.assign cmpy_person
      expect(subject.display_tasks('mine-open'))
        .to match_array [task_company_reg]
    end
    it 'gets my closed tasks' do
      # status == done
      task_company_reg.assign cmpy_person
      task_company_reg.work_in_progress
      task_company_reg.complete
      expect(subject.display_tasks('mine-closed'))
        .to match_array [task_company_reg]
    end
  end
end
