require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplicationsController, type: :controller do

	describe 'PATCH accept' do
		let(:job) { FactoryGirl.create(:job) }
		let(:job_seeker) { FactoryGirl.create(:job_seeker) }
		let(:invalid_application) { FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker, status: 'accepted')}
		let(:valid_application) { FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker) }

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
				expect(flash[:alert]).to eq "Invalid action on inactive job application."
			end
			it 'redirect to the specific job application index page' do
				expect(response).to redirect_to(applications_job_url(invalid_application.job))
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
				expect(flash[:info]).to eq "Job application accepted."
			end
			it 'redirect to the specific job application index page' do
				expect(response).to redirect_to(applications_job_url(valid_application.job))
			end
		end
	end

	describe 'GET show' do
		context 'Invalid Request' do
			it 'shows a flash[:alert]' do
				get :show, id: anything
				expect(flash[:alert]).to eq "Job Application Entry not found."
			end
		end
	end
end