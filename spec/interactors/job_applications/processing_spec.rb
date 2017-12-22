require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe JobApplications::Processing do
  let!(:agency)       { FactoryBot.build(:agency) }
  let(:job_developer) { FactoryBot.build(:job_developer, agency: agency) }
  let(:company)       { FactoryBot.build(:company) }
  let(:hr_jane)       { FactoryBot.create(:company_person, company: company) }
  let(:job_seeker)    { FactoryBot.build(:job_seeker) }
  let(:service)       { JobSeekers::AssignAgencyPerson.new }

  describe 'call' do
    before(:each) do
      allow(Event).to receive(:create)
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context 'when job application is not active' do
      it 'throws an exception' do
        job_application = FactoryBot.build(:job_application, status: :processing)
        expect do
          subject.call(job_application, hr_jane)
        end.to raise_error(JobApplications::JobNotActive)
      end
    end

    context 'when job application is active' do
      let(:job_seeker) { FactoryBot.build(:job_seeker) }
      let(:job_application) do
        FactoryBot.build(:job_application, job_seeker: job_seeker, status: :active)
      end

      it 'change the status of the application to processing' do
        subject.call(job_application, hr_jane)
        expect(job_application.processing?).to be(true)
      end

      it 'assigns the job application review to the company person' do
        TestTaskHelper.new_review_job_application_task(job_application, company)
        subject.call(job_application, hr_jane)
        task = Task.find_by_owner_user_open(hr_jane)
        expect(task.count).to be(1)
        expect(task.first.task_type).to eq('job_application')
        expect(task.first.status).to eq(Task::STATUS[:ASSIGNED])
      end

      context 'when the job application review task' do
        context 'is already assigned to the "HR Jane"' do
          it 'maintain the Jane as the assigned person' do
            task = TestTaskHelper.new_review_job_application_task(
              job_application,
              company
            )
            task.assign(hr_jane)
            subject.call(job_application, hr_jane)
            task = Task.find_by_owner_user_open(hr_jane)
            expect(task.count).to be(1)
            expect(task.first.task_type).to eq('job_application')
            expect(task.first.status).to eq(Task::STATUS[:ASSIGNED])
          end
        end

        context 'is already assigned to the "HR John"' do
          it 'change the assigned person to Jane' do
            hr_john = FactoryBot.create(:company_person, company: company)
            task = TestTaskHelper.new_review_job_application_task(
              job_application,
              company
            )
            task.assign(hr_john)
            subject.call(job_application, hr_jane)
            task = Task.find_by_owner_user_open(hr_jane)
            expect(task.count).to be(1)
            expect(task.first.task_type).to eq('job_application')
            expect(task.first.status).to eq(Task::STATUS[:ASSIGNED])
          end
        end
      end

      context 'when the job seeker as a job developer assigned' do
        let(:job_developer) { FactoryBot.build(:job_developer) }
        before(:each) do
          allow(job_seeker).to receive(:job_developer).and_return(job_developer)
          subject.call(job_application, hr_jane)
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
          subject.call(job_application, hr_jane)
        end

        it 'create Job Application processing event' do
          expect(Event).not_to have_received(:create)
        end
      end
    end
  end
end
