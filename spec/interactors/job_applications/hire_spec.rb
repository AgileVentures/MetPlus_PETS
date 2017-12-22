require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe JobApplications::Hire do
  describe '#call' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      allow(Event).to receive(:create)
    end

    context 'when application is not accepted' do
      let(:job_application) { FactoryBot.build(:not_accepted_job_application) }
      it 'raises JobNotActive exception' do
        expect do
          subject.call(job_application)
        end.to raise_error(JobApplications::JobNotActive)
      end
    end

    context 'when application is accepted' do
      let(:job_application) { FactoryBot.build(:job_application, status: :accepted) }
      it 'raises JobNotActive exception' do
        expect do
          subject.call(job_application)
        end.to raise_error(JobApplications::JobNotActive)
      end
    end

    context 'when application is active' do
      let(:company) { FactoryBot.create(:company) }
      let(:job) { FactoryBot.create(:job, company: company) }

      let!(:jane_application) do
        jane = FactoryBot.create(:job_seeker, first_name: 'Jane')
        job_application = FactoryBot.create(:job_application, job_seeker: jane, job: job)
        TestTaskHelper.new_review_job_application_task(job_application, company)
        job_application
      end
      let!(:joe_application) do
        joe = FactoryBot.create(:job_seeker, first_name: 'Joe')
        job_application = FactoryBot.create(:job_application, job_seeker: joe, job: job)
        TestTaskHelper.new_review_job_application_task(job_application, company)
        job_application
      end

      it 'changes state of job application to accepted' do
        subject.call(jane_application)

        all_job_applications = JobApplication.all
        expect(all_job_applications.count).to be(2)
        jane_application = all_job_applications.select do |application|
          application.job_seeker.first_name == 'Jane'
        end.first
        expect(all_job_applications.count).to be(2)
        joe_application = all_job_applications.select do |application|
          application.job_seeker.first_name == 'Joe'
        end.first
        expect(jane_application.status).to eq('accepted')
        expect(joe_application.status).to eq('not_accepted')
      end

      it 'closes all job application tasks associated with the job' do
        subject.call(jane_application)
        Task.all.each do |task|
          expect(task.status).to eq(TestTaskHelper::STATUS[:DONE])
        end
      end

      context 'when the job seeker as a job developer associated' do
        let(:job_developer) { FactoryBot.build(:job_developer) }
        before(:each) do
          allow(jane_application.job_seeker)
            .to receive(:job_developer).and_return(job_developer)
          subject.call(jane_application)
        end

        it 'creates a application accepted notification' do
          expect(Event).to have_received(:create).with(:APP_ACCEPTED, jane_application)
        end
      end

      context 'when the job seeker as no job developer associated' do
        before(:each) do
          allow(jane_application.job_seeker)
            .to receive(:job_developer).and_return(nil)
          subject.call(jane_application)
        end

        it 'does not create any notification' do
          expect(Event).not_to have_received(:create)
        end
      end
    end
  end
end
