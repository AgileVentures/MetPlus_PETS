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
    let(:company) { FactoryGirl.create(:company) }
    let(:job) { FactoryGirl.create(:job, company: company) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:invalid_application) do
      FactoryGirl.create(:job_application,
                         job: job, job_seeker: job_seeker,
                         status: 'accepted')
    end
    let(:valid_application) do
      FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker)
    end

    describe 'authorized access' do
      context 'company admin' do
        before(:each) do
          @company_admin = FactoryGirl.create(:company_admin, company: company)
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

        context 'Valid Job Application Accepted' do
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
                                            valid_application.job))
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
                                            valid_application.job))
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
      let(:company2) { FactoryGirl.create(:company) }
      let(:company_admin2) do
        FactoryGirl.create(:company_admin,
                           company: company2)
      end
      let(:company_contact2) do
        FactoryGirl.create(:company_contact,
                           company: company2)
      end
      let(:agency) { FactoryGirl.create(:agency) }
      let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
      let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
      let(:case_manager) { FactoryGirl.create(:case_manager, agency: agency) }

      context 'Accept' do
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
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { job_seeker }
          end
        end
        context 'Agency Admin' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { agency_admin }
          end
        end
        context 'Job Developer' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { job_developer }
          end
        end
        context 'Case Manager' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { case_manager }
          end
        end

        context 'Company Admin from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { company_admin2 }
          end
        end
        context 'Company Contact from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :accept, id: valid_application }
            let(:user) { company_contact2 }
          end
        end
      end
      context 'Reject' do
        context 'not logged in' do
          context 'company_admin' do
            let(:request) { patch :reject, id: company_admin }
            it_behaves_like 'unauthenticated request'
          end
          context 'company_contact' do
            let(:request) { patch :reject, id: company_contact }
            it_behaves_like 'unauthenticated request'
          end
        end
        context 'Job Seeker' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { job_seeker }
          end
        end
        context 'Agency Admin' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { agency_admin }
          end
        end
        context 'Job Developer' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { job_developer }
          end
        end
        context 'Case Manager' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { case_manager }
          end
        end

        context 'Company Admin from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { company_admin2 }
          end
        end
        context 'Company Contact from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { patch :reject, id: valid_application }
            let(:user) { company_contact2 }
          end
        end
      end
      context 'Show' do
        context 'not logged in' do
          context 'company_admin' do
            let(:request) { get :show, id: company_admin }
            it_behaves_like 'unauthenticated request'
          end
          context 'company_contact' do
            let(:request) { get :show, id: company_contact }
            it_behaves_like 'unauthenticated request'
          end
        end
        context 'Job Seeker' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { job_seeker }
          end
        end
        context 'Agency Admin' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { agency_admin }
          end
        end
        context 'Job Developer' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { job_developer }
          end
        end
        context 'Case Manager' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { case_manager }
          end
        end

        context 'Company Admin from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { company_admin2 }
          end
        end
        context 'Company Contact from another company' do
          before(:each) do
            stub_cruncher_authenticate
            stub_cruncher_job_create
          end
          it_behaves_like 'unauthorized' do
            let(:request) { get :show, id: valid_application }
            let(:user) { company_contact2 }
          end
        end
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

  describe 'GET download_resume' do
    context 'Successful download' do
      it 'does not raise exception' do
        stub_cruncher_file_download('files/Admin-Assistant-Resume.pdf')
        get :download_resume, id: valid_application
        expect(response).to_not set_flash
      end
    end
    context 'Error: Resume not found in DB' do
      it 'sets flash message' do
        get :download_resume, id: invalid_application2
        expect(flash[:alert]).to eq 'Error: Resume not found in DB'
      end
    end
    context 'Error: Resume not found in Cruncher' do
      it 'sets flash message' do
        stub_cruncher_file_download_notfound
        get :download_resume, id: invalid_application
        expect(flash[:alert]).to eq 'Error: Resume not found in Cruncher'
      end
    end
  end
end
