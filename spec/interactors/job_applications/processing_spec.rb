require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplications::Processing do
  let!(:agency)       { FactoryGirl.create(:agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryGirl.create(:job_seeker) }
  let(:service)       { JobSeekers::AssignAgencyPerson.new }

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
          subject.call(job_application)
        end.to raise_error(JobApplications::JobNotActive)
      end
    end

    context 'when job application is active' do
      let(:job_seeker) { FactoryGirl.build(:job_seeker) }
      let(:job_application) do
        FactoryGirl.build(:job_application, job_seeker: job_seeker, status: :active)
      end

      it 'change the status of the application to processing' do
        subject.call(job_application)
        expect(job_application.processing?).to be(true)        
      end
      
      context 'when the job seeker as a job developer assigned' do    
        let(:job_developer) { FactoryGirl.build(:job_developer) }
        before(:each) do
          allow(job_seeker).to receive(:job_developer).and_return(job_developer)
          subject.call(job_application)
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
          subject.call(job_application)
        end

        it 'create Job Application processing event' do
          expect(Event).not_to have_received(:create)
        end
      end
    end
  end
end