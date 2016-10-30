require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'unauthorized' do
  before :each do
    warden.set_user user
    request
  end

  it 'redirects to the home page' do
    expect(response).to redirect_to(root_path)
  end

  it 'sets the flash' do
    expect(flash[:alert]).to match(/^You are not authorized to/)
  end
end

RSpec.shared_examples 'unauthenticated request' do
  before do
    request
  end

  it 'redirects to the home page' do
    expect(response).to redirect_to(root_path)
  end

  it 'sets the flash' do
    expect(flash[:alert]).to match(/You need to login to/)
  end
end

RSpec.describe JobApplicationsController, type: :controller do
  describe 'PATCH accept' do
    let(:job) { FactoryGirl.create(:job) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:invalid_application) do
      FactoryGirl.create(:job_application,
                         job: job, job_seeker: job_seeker,
                         status: 'accepted')
    end
    let(:valid_application) do
      FactoryGirl.create(:job_application, job: job,
                                           job_seeker: job_seeker)
    end

    describe 'authorized access' do
      context 'company admin' do
        before(:each) do
          @company_admin = FactoryGirl.create(:company_admin)
          sign_in @company_admin
        end
        context 'Invalid Request' do
          it 'shows a flash[:alert]' do
            get :show, id: anything
            expect(flash[:alert]).to eq 'Job Application Entry not found.'
          end
        end

        context 'Invalid Job Application' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
            patch :accept, id: invalid_application
          end
          it 'look for the invalid application' do
            expect(assigns(:job_application)).to eq invalid_application
          end
          it 'show a flash[:alert]' do
            expect(flash[:alert]).to eq 'Invalid action on'\
							' inactive job application.'
          end
          it 'redirect to the specific job application index page' do
            expect(response).to redirect_to(applications_job_url(
                                              invalid_application.job
            ))
          end
        end

        context 'Valid Job Application' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
            expect_any_instance_of(JobApplication).to receive(:accept)
            patch :accept, id: valid_application
          end
          it 'show a flash[:info]' do
            expect(flash[:info]).to eq 'Job application accepted.'
          end
          it 'redirect to the specific job application index page' do
            expect(response).to redirect_to(applications_job_url(
                                              valid_application.job
            ))
          end
        end

        context 'Valid Job Application Rejected' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
            expect_any_instance_of(JobApplication).to receive(:reject)
            patch :reject, id: valid_application
          end
          it 'show a flash[:info]' do
            expect(flash[:notice]).to eq 'Job application rejected.'
          end
          it 'redirect to the specific job application index page' do
            expect(response).to redirect_to(applications_job_url(
                                              valid_application.job
            ))
          end
        end
      end
    end
    describe 'unauthorized access' do
      let(:company) { FactoryGirl.create(:company) }
      let(:company_admin) do
        FactoryGirl.create(:company_admin,
                           company: company)
      end
      let(:company_contact) do
        FactoryGirl.create(:company_contact,
                           company: company)
      end

      context 'not logged in' do
        context 'company_admin' do
          let(:request) { patch :accept, id: company_admin }
          it_behaves_like 'unauthenticated request'
        end
        context 'company_contact' do
          let(:request) { patch :accept, id: company_contact }
          it_behaves_like 'unauthenticated request'
        end
      end
      context 'Job Seeker' do
        let(:job) { FactoryGirl.create(:job) }
        let(:valid_application) do
          FactoryGirl.create(:job_application, job: job,
                                               job_seeker: job_seeker)
        end
        before(:each) do
          stub_cruncher_authenticate
          stub_cruncher_job_create
        end
        it_behaves_like 'unauthorized' do
          let(:request) { patch :accept, id: job_seeker }
          let(:user) { job_seeker }
        end
      end
    end
  end
end
