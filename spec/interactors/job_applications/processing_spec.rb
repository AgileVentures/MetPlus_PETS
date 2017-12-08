require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe JobApplications::Processing do
  let!(:agency)        { FactoryGirl.build(:agency) }
  let(:job_developer)  { FactoryGirl.build(:job_developer, agency: agency) }
  let(:company)        { FactoryGirl.build(:company) }
  let(:company_person) { FactoryGirl.create(:company_person, company: company) }
  let(:job_seeker)     { FactoryGirl.build(:job_seeker) }
  let(:service)        { JobSeekers::AssignAgencyPerson.new }

  describe 'call' do
    before(:each) do
      allow(Event).to receive(:create)
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context 'when job application is not active' do
      it 'throws an exception' do
        job_application = FactoryGirl.build(:job_application, status: :processing)
        expect do
          subject.call(job_application, company_person)
        end.to raise_error(JobApplications::JobNotActive)
      end
    end

    context 'when job application is active' do
      let(:job_seeker) { FactoryGirl.build(:job_seeker) }
      let(:job_application) do
        FactoryGirl.build(:job_application, job_seeker: job_seeker, status: :active)
      end

      it 'change the status of the application to processing' do
        subject.call(job_application, company_person)
        expect(job_application.processing?).to be(true)
      end

      it 'assigns the job application review to the company person' do
        TestTaskHelper.new_review_job_application_task(job_application, company)
        subject.call(job_application, company_person)
        task = Task.find_by_owner_user_open(company_person)
        expect(task.count).to be(1)
        expect(task.first.task_type).to eq('job_application')
        expect(task.first.status).to eq(Task::STATUS[:ASSIGNED])
      end

      context 'when the job seeker as a job developer assigned' do
        let(:job_developer) { FactoryGirl.build(:job_developer) }
        before(:each) do
          allow(job_seeker).to receive(:job_developer).and_return(job_developer)
          subject.call(job_application, company_person)
        end

        it 'create Job Application processing event' do
          expect(Event).to have_received(:create)
            .with(
              :APP_PROCESSING,
              job_application
            )
        end
      end

      context 'when the job seeker do not have a job developer assigned' do
        before(:each) do
          subject.call(job_application, company_person)
        end

        it 'create Job Application processing event' do
          expect(Event).not_to have_received(:create)
        end
      end
    end
  end
end
