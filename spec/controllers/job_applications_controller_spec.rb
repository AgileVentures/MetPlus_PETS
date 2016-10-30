require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplicationsController, type: :controller do

  describe 'PATCH accept' do
    let(:job) { FactoryGirl.create(:job) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:invalid_application) do 
      FactoryGirl.create(:job_application, 
        job: job, job_seeker: job_seeker, status: 'accepted') 
    end
    let(:valid_application) do 
      FactoryGirl.create(:job_application, 
        job: job, job_seeker: job_seeker) 
    end

    context 'Invalid Job Application' do
      before (:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
        patch :accept, id: invalid_application
      end
      it 'look for the invalid application' do
        expect(assigns(:job_application)).to eq invalid_application
      end
      it 'show a flash[:alert]' do
        expect(flash[:alert]).
        to eq 'Invalid action on inactive job application.'
      end
      it 'redirect to the specific job application index page' do
        expect(response).
        to redirect_to(applications_job_url(invalid_application.job))
      end
    end

    context 'Valid Job Application' do
      before (:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
        expect_any_instance_of(JobApplication).to receive(:accept)
        patch :accept, id: valid_application
      end
      it 'show a flash[:info]' do
        expect(flash[:info]).to eq 'Job application accepted.'
      end
      it 'redirect to the specific job application index page' do
        expect(response).
        to redirect_to(applications_job_url(valid_application.job))
      end
    end


    context 'Valid Job Application Rejected' do
      before (:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
        expect_any_instance_of(JobApplication).to receive(:reject)
        patch :reject, id: valid_application
      end
      it 'show a flash[:info]' do
        expect(flash[:notice]).to eq 'Job application rejected.'
      end
      it 'redirect to the specific job application index page' do
        expect(response).
        to redirect_to(applications_job_url(valid_application.job))
      end
    end
  end

  describe 'GET show' do
    context 'Invalid Request' do
      it 'shows a flash[:alert]' do
        get :show, id: anything
        expect(flash[:alert]).to eq 'Job Application Entry not found.'
      end
    end
  end

  describe 'GET #list' do
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:job1) { FactoryGirl.create(:job) }
    let(:job2) { FactoryGirl.create(:job) }
    let(:job3) { FactoryGirl.create(:job) }
    let(:app1) do 
      FactoryGirl.create(:job_application,
                               job: job1, job_seeker: job_seeker) 
    end
    let(:app2) do 
      FactoryGirl.create(:job_application,
                               job: job2, job_seeker: job_seeker) 
    end
    let(:app3) do 
      FactoryGirl.create(:job_application,
                               job: job3, job_seeker: job_seeker) 
    end
    let(:app4) do 
      FactoryGirl.create(:job_application,
                               job: job3,
                               job_seeker: FactoryGirl.create(:job_seeker)) 
    end

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      xhr :get, :list, type: 'job_seeker', entity_id: job_seeker
    end

    it 'assigns jobs for view' do
      expect(assigns(:job_applications)).to include(app1, app2, app3)
      expect(assigns(:job_applications)).not_to include(app4)
    end

    it 'renders partial for applications' do
      expect(response).to render_template(partial: 'jobs/_applied_job_list')
    end
  end
end