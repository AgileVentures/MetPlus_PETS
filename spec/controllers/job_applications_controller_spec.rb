require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'denies access to unauthorized people' do
  context 'agency people' do
    it_behaves_like 'unauthorized request' do
      let(:user) { agency_admin }
    end

    it_behaves_like 'unauthorized request' do
      let(:user) { job_developer }
    end

    it_behaves_like 'unauthorized request' do
      let(:user) { case_manager }
    end
  end

  context 'company people who don\'t belong to the job posting company' do
    it_behaves_like 'unauthorized request' do
      let(:user) { company_contact2 }
    end

    it_behaves_like 'unauthorized request' do
      let(:user) { company_admin2 }
    end
  end

  context 'job seeker' do
    it_behaves_like 'unauthorized request' do
      let(:user) { job_seeker }
    end
  end
end

RSpec.describe JobApplicationsController, type: :controller do
  let(:company)       { FactoryBot.create(:company) }
  let(:job)           { FactoryBot.create(:job, company: company) }
  let(:job_seeker)    { FactoryBot.create(:job_seeker) }
  let(:job_seeker2)   { FactoryBot.create(:job_seeker) }
  let!(:company_admin) { FactoryBot.create(:company_admin, company: company) }
  let(:company_contact) { FactoryBot.create(:company_contact, company: company) }
  let(:inactive_application) do
    FactoryBot.create(:job_application,
                      job: job, job_seeker: job_seeker2,
                      status: 'accepted')
  end
  let(:valid_application) do
    FactoryBot.create(:job_application, job: job, job_seeker: job_seeker)
  end
  let(:agency)       { FactoryBot.create(:agency) }
  let(:agency_admin) { FactoryBot.create(:agency_admin, agency: agency) }
  let(:company2)     { FactoryBot.create(:company) }
  let(:company_admin2) do
    FactoryBot.create(:company_admin,
                      company: company2)
  end
  let(:company_contact2) do
    FactoryBot.create(:company_contact,
                      company: company2)
  end
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }

  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  describe 'GET #show' do
    let(:request) { get :show, params: { id: valid_application } }

    context 'unauthenticated' do
      it_behaves_like 'unauthenticated request'
    end

    context 'authenticated' do
      describe 'authorized access' do
        before do
          sign_in company_admin
          request
        end

        it 'should return http success' do
          expect(response).to have_http_status(200)
        end

        it 'renders the show template' do
          expect(response).to render_template(:show)
        end
      end

      describe 'unauthorized access' do
        it_behaves_like 'denies access to unauthorized people'
      end
    end
  end

  describe 'PATCH #accept' do
    let(:request) { patch :accept, params: { id: valid_application } }

    context 'unauthenticated' do
      it_behaves_like 'unauthenticated request'
    end

    context 'authenticated' do
      describe 'authorized access' do
        let(:hire_mock) { double(JobApplications::Hire) }
        before(:each) do
          sign_in company_admin
          allow(JobApplications::Hire).to receive(:new)
            .and_return(hire_mock)
        end

        context 'inactive job application' do
          before(:each) do
            allow(hire_mock).to receive(:call).and_raise(JobApplications::JobNotActive)
            patch :accept, params: { id: inactive_application }
          end

          it 'show a flash message of type alert' do
            expect(flash[:alert]).to eq 'Invalid action on'\
                ' inactive job application.'
          end

          it 'redirect to the specific job show page' do
            expect(response).to redirect_to(job_url(inactive_application.job))
          end

          it 'calls interactor with the job application' do
            expect(hire_mock).to have_received(:call).with(inactive_application)
          end
        end

        context 'valid job application accepted' do
          before(:each) do
            allow(hire_mock).to receive(:call)
            request
          end

          it 'show a flash message of type info' do
            expect(flash[:info]).to eq 'Job application accepted.'
          end

          it 'redirect to the specific job show page' do
            expect(response).to redirect_to(job_url(valid_application.job))
          end

          it 'calls interactor with the job application' do
            expect(hire_mock).to have_received(:call).with(valid_application)
          end
        end
      end

      describe 'unauthorized access' do
        it_behaves_like 'denies access to unauthorized people'
      end
    end
  end

  describe 'PATCH #reject' do
    let(:request) do
      patch :reject, params: { id: valid_application,
                               reason_for_rejection: 'Skills did not match' }
    end

    context 'unauthenticated' do
      it_behaves_like 'unauthenticated request'
    end

    context 'authenticated' do
      describe 'authorized access' do
        let(:reject_mock) { double(JobApplications::Reject) }

        before(:each) do
          sign_in company_admin
          allow(JobApplications::Reject).to receive(:new)
            .and_return(reject_mock)
        end

        context 'inactive job application' do
          before(:each) do
            allow(reject_mock).to receive(:call).and_raise(JobApplications::JobNotActive)
            patch :reject, params: { id: inactive_application }
          end

          it 'show a flash message of type alert' do
            expect(flash[:alert]).to eq 'Cannot reject an '\
              'inactive job application.'
          end

          it 'redirect to the specific job application show page' do
            expect(response).to redirect_to(application_path(inactive_application))
          end

          it 'calls interactor with the job application' do
            expect(reject_mock).to have_received(:call).with(inactive_application, nil)
          end
        end

        context 'valid job application rejected' do
          before(:each) do
            allow(reject_mock).to receive(:call)
            request
          end

          it 'show a flash message of type notice' do
            expect(flash[:notice]).to eq 'Job application rejected.'
          end

          it 'redirect to the specific job application show page' do
            expect(response).to redirect_to(job_url(valid_application.job))
          end

          it 'calls interactor with the job application' do
            expect(reject_mock)
              .to have_received(:call).with(valid_application, 'Skills did not match')
          end
        end
      end

      describe 'unauthorized access' do
        it_behaves_like 'denies access to unauthorized people'
      end
    end
  end

  describe 'PATCH #process_application' do
    let(:request) { patch :process_application, params: { id: valid_application } }

    context 'unauthenticated' do
      it_behaves_like 'unauthenticated request'
    end

    context 'authenticated' do
      describe 'authorized access' do
        let(:application_process_mock) { double(JobApplications::Processing) }
        before(:each) do
          sign_in company_admin
          allow(JobApplications::Processing).to receive(:new)
            .and_return(application_process_mock)
        end

        context 'inactive job application' do
          before(:each) do
            allow(application_process_mock)
              .to receive(:call).and_raise(JobApplications::JobNotActive)
            patch :process_application, params: { id: inactive_application }
          end

          it 'show a flash message of type alert' do
            expect(flash[:alert]).to eq 'Invalid action on'\
                ' inactive job application.'
          end

          it 'redirect to the specific job show page' do
            expect(response).to redirect_to(job_url(inactive_application.job))
          end

          it 'interator to have been called' do
            expect(application_process_mock)
              .to have_received(:call)
              .with(inactive_application, company_admin.user)
          end
        end

        context 'valid job application started processing' do
          before(:each) do
            allow(application_process_mock).to receive(:call)
            request
          end

          it 'show a flash message of type info' do
            expect(flash[:info]).to eq 'Job application processing.'
          end

          it 'redirect to the specific job show page' do
            expect(response).to redirect_to(job_url(valid_application.job))
          end

          it 'interator to have been called' do
            expect(application_process_mock)
              .to have_received(:call)
              .with(valid_application, company_admin.user)
          end
        end
      end

      describe 'unauthorized access' do
        it_behaves_like 'denies access to unauthorized people'
      end
    end
  end

  describe 'GET #list' do
    let(:company) { FactoryBot.create(:company) }
    let(:job1) { FactoryBot.create(:job) }
    let(:job2) { FactoryBot.create(:job) }
    let(:job3) { FactoryBot.create(:job) }
    let!(:job4) { FactoryBot.create(:job, company: company) }
    let(:app1) do
      FactoryBot.create(:job_application, job: job1, job_seeker: job_seeker)
    end
    let(:app2) do
      FactoryBot.create(:job_application, job: job2, job_seeker: job_seeker)
    end
    let(:app3) do
      FactoryBot.create(:job_application, job: job3, job_seeker: job_seeker)
    end
    let!(:app4) do
      FactoryBot.create(:job_application,
                        job: job3, job_seeker: FactoryBot.create(:job_seeker))
    end
    let!(:app5_inactive_company) do
      company.inactive!
      FactoryBot.create(:job_application, job: job4, job_seeker: job_seeker)
    end

    before(:each) do
      get :list, params: { type: 'job_seeker-default', entity_id: job_seeker }, xhr: true
    end

    it 'assigns jobs for view' do
      expect(assigns(:job_applications)).to include(app1, app2, app3)
      expect(assigns(:job_applications)).not_to include(app4, app5_inactive_company)
    end

    it 'renders partial for applications' do
      expect(response).to render_template(partial: 'jobs/_applied_job_list')
    end
  end
end
