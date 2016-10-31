require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'unauthorized' do
  before :each do
    warden.set_user user
  end
  it 'redirects to the home page' do
    expect(response).to redirect_to(root_path)
  end
  it 'sets the flash' do
    expect(flash[:alert]).to eq 'You are not authorized to to perform this action.'
  end
  # it 'sets the flash' do
  #   expect(flash[:alert]).to eq 'You need to login to perform this action.'
  # end
end

RSpec.shared_examples 'authorized' do
  before :each do
    warden.set_user user
  end
  it 'returns http success' do
    expect(response).to have_http_status(:success)
  end
end

RSpec.describe JobSeekersController, type: :controller do
  describe 'GET #new' do
    context 'visitor' do
      it_behaves_like "authorized" { let(:user) { nil } }
    end

    it 'renders new template' do
      get :new
      expect(response).to render_template 'new'
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'valid attributes' do
      before(:each) do
        js_status = FactoryGirl.create(:job_seeker_status)
        ActionMailer::Base.deliveries.clear
        @js_hash = FactoryGirl.attributes_for(:job_seeker)
                              .merge(FactoryGirl.attributes_for(:user))
                              .merge(job_seeker_status_id: js_status.id)
        @js_hash[:address_attributes] = FactoryGirl.attributes_for(:address,
                                          zipcode: '54321')
        post :create, job_seeker: @js_hash
      end

      it 'sets flash message' do
        message = 'A message with a confirmation and link has been sent to '\
                  'your email address. Please follow the link to activate '\
                  'your account.'
        expect(flash[:notice]).to eq message
      end

      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to root page' do
        expect(response).to redirect_to(root_path)
      end
      it 'check address' do
        js = User.find_by_email(@js_hash[:email]).pets_user
        expect(js.address.zipcode).to eq '54321'
      end
      describe 'confirmation email' do
        # Include email_spec modules here, not in rails_helper because they
        # conflict with the capybara-email#open_email method which lets us
        # call current_email.click_link below.
        # Re: https://github.com/dockyard/capybara-email/issues/34#issuecomment-49528389
        include EmailSpec::Helpers
        include EmailSpec::Matchers

        # open the most recent email sent to user_email
        subject { open_email(@js_hash[:email]) }

        # Verify email details
        it { is_expected.to deliver_to(@js_hash[:email]) }
        it { is_expected.to have_body_text(/Welcome #{@js_hash[:first_name]} #{@js_hash[:last_name]}!/) }
        it { is_expected.to have_body_text(/You can confirm your account/) }
        it { is_expected.to have_body_text(/users\/confirmation\?confirmation/) }
        it { is_expected.to have_subject(/Confirmation instructions/) }
      end
    end

    context 'valid attributes and resume file upload' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload

        ActionMailer::Base.deliveries.clear

        js_status = FactoryGirl.create(:job_seeker_status)
        @js_hash = FactoryGirl.attributes_for(:job_seeker,
                    resume: fixture_file_upload('files/Janitor-Resume.doc'))
                             .merge(FactoryGirl.attributes_for(:user))
                             .merge(job_seeker_status_id: js_status.id)
      end

      it 'saves job seeker' do
        expect { post :create, job_seeker: @js_hash }
          .to change(JobSeeker, :count).by(+1)
      end
      it 'saves resume record' do
        expect { post :create, job_seeker: @js_hash }
          .to change(Resume, :count).by(+1)
      end
    end

    context 'invalid attributes' do
      before(:each) do
        @jobseeker = FactoryGirl.create(:job_seeker)
        @user = FactoryGirl.create(:user)
        @jobseekerstatus = FactoryGirl.create(:job_seeker_status)
        @jobseeker.assign_attributes(year_of_birth: '198')
        @user.assign_attributes(first_name: 'John', last_name: 'Smith',
                                phone: '890-789-9087')
        @jobseekerstatus.assign_attributes(description: 'MyText')
        @jobseeker.valid?
        js1_hash = FactoryGirl.attributes_for(:job_seeker,
                      year_of_birth: '198',
                      resume: fixture_file_upload('files/Janitor-Resume.doc'))
                    .merge(FactoryGirl.attributes_for(:user,
                      first_name: 'John',
                      last_name: 'Smith', 
                      phone: '890-789-9087'))
                    .merge(FactoryGirl.attributes_for(:job_seeker_status,
                      description: 'MyText'))
                    .merge(FactoryGirl.attributes_for(:address,
                      zipcode: '12345131231231231231236'))
        post :create, job_seeker: js1_hash
      end
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PATCH #update' do
    context ' updated by job seeker ' do
      let(:jobseeker) { FactoryGirl.create(:job_seeker) }
      let(:js_status) { FactoryGirl.create(:job_seeker_status) }
      let(:password) { jobseeker.encrypted_password }
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload

        sign_in jobseeker
      end

      context 'successful initial résumé upload' do
        it 'saves the first resume record' do
          expect do
            patch :update,
                  id: jobseeker,
                  job_seeker: FactoryGirl.attributes_for(:job_seeker,
                    resume: fixture_file_upload('files/Janitor-Resume.doc'))
          end
            .to change(Resume, :count).by(+1)
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
        end
      end

      context 'valid attributes without password change' do
        before(:each) do
          FactoryGirl.create(:resume, 
            file_name: 'Janitor-Resume.doc',
            file: fixture_file_upload('files/Janitor-Resume.doc'),
            job_seeker: jobseeker)
          patch :update,
            id: jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
              year_of_birth: '1980', first_name: 'John',
              last_name: 'Smith', password: '',
              password_confirmation: '', phone: '780-890-8976',
              resume: fixture_file_upload('files/Admin-Assistant-Resume.pdf'))
              .merge(job_seeker_status_id: js_status.id)
              .merge(address_attributes: FactoryGirl.attributes_for(:address,
                zipcode: '12346'))
          jobseeker.reload
        end
        it 'sets the valid attributes' do
          expect(jobseeker.first_name).to eq 'John'
          expect(jobseeker.last_name).to eq 'Smith'
          expect(jobseeker.year_of_birth).to eq '1980'
          expect(jobseeker.status.id).to eq js_status.id
          expect(jobseeker.address.zipcode).to eq '12346'
          expect(jobseeker.resumes[0].file_name).
          to eq 'Admin-Assistant-Resume.pdf'
        end
        it 'dont change password' do
          expect(jobseeker.encrypted_password).to eq password
        end
        it 'sets flash message' do
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
        end
        it 'returns redirect status' do
          expect(response).to have_http_status(:redirect)
        end
        it 'redirects to mainpage' do
          expect(response).to redirect_to(root_path)
        end
      end

      context 'unsuccessful résumé upload' do
        render_views

        before(:each) do
          FactoryGirl.create(:resume,
            file_name: 'Janitor-Resume.doc',
            file: fixture_file_upload('files/Janitor-Resume.doc'),
            job_seeker: jobseeker)
          patch :update, 
                id: jobseeker,
                job_seeker: FactoryGirl.attributes_for(:job_seeker,
                  resume: fixture_file_upload('files/Example Excel File.xls'))
          jobseeker.reload
        end
        it 'does not update existing resume' do
          expect(jobseeker.resumes[0].file_name).to eq 'Janitor-Resume.doc'
        end
        it 'output file unsupported message' do
          expect(response.body).to have_content('unsupported file type')
        end
        it 'renders edit template' do
          expect(response).to render_template('edit')
        end
      end

      context 'invalid attributes' do
        before(:each) do
          jobseeker.assign_attributes(year_of_birth: '198')
          jobseeker.valid?
          patch :update,
                id: jobseeker,
                job_seeker: FactoryGirl.attributes_for(:job_seeker,
                  year_of_birth: '198',
                  resume: '')
        end
        it 'renders edit template' do
          expect(response).to render_template('edit')
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    context " updated by job seeker's case manager " do
      let(:agency) { FactoryGirl.create(:agency) }
      let(:jobseeker) { FactoryGirl.create(:job_seeker, phone: '123-456-7890') }
      let(:case_manager) { FactoryGirl.create(:case_manager, agency: agency) }
      let(:password) { jobseeker.encrypted_password }
      before(:each) do
        sign_in case_manager
        jobseeker.assign_case_manager(case_manager, agency)
      end
      context 'valid attributes' do
        it 'locates the requested @jobseeker' do
          patch :update,
                id: case_manager.job_seekers.first,
                job_seeker: FactoryGirl.attributes_for(:job_seeker)
          expect(assigns(:jobseeker)).to eq(jobseeker)
        end
        it "changes @jobseeker's attribute" do
          patch :update,
                id: case_manager.job_seekers.first,
                job_seeker: FactoryGirl.attributes_for(:job_seeker,
                  phone: '111-111-1111')
          jobseeker.reload
          expect(jobseeker.phone).to eq('111-111-1111')
        end
        it 'sets flash message and redirects to job seeker show page' do
          patch :update,
                id: case_manager.job_seekers.first,
                job_seeker: FactoryGirl.attributes_for(:job_seeker)
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
          expect(response).to redirect_to jobseeker
        end
      end

      context 'unauthorized attributes' do
        before(:each) do
          patch :update,
                id: case_manager.job_seekers.first,
                job_seeker: FactoryGirl.attributes_for(:job_seeker,
                  year_of_birth: '1988',
                  password: '123345',
                  password_confirmation: '123345')
          jobseeker.reload
        end
        it "does not change job seeker's attribute" do
          expect(jobseeker.year_of_birth).to eq('1998')
          expect(jobseeker.encrypted_password).to eq password
        end
      end

      context 'invalid attributes' do
        before(:each) do
          patch :update,
                id: case_manager.job_seekers.first, 
                job_seeker: FactoryGirl.attributes_for(:job_seeker,
                  phone: '123')
          jobseeker.reload
        end
        it "does not change job seeker's attribute" do
          expect(jobseeker.phone).to eq('123-456-7890')
        end
        it 're-renders the edit template' do
          expect(response).to render_template('edit')
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:jobseeker) { FactoryGirl.create(:job_seeker) }
    let(:resume) do
      FactoryGirl.create(:resume, 
                        file_name: 'Janitor-Resume.doc',
                        file: fixture_file_upload('files/Janitor-Resume.doc'),
                        job_seeker: jobseeker)
    end
    let(:agency) { FactoryGirl.create(:agency) }
    let(:case_manager) { FactoryGirl.create(:case_manager, agency: agency) }

    context 'edited by job seeker' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload

        sign_in jobseeker
        get :edit, id: jobseeker
      end

      it 'assigns jobseeker and current_resume for view' do
        expect(assigns(:jobseeker)).to eq jobseeker
        expect(assigns(:current_resume)).to eq jobseeker.resumes[0]
      end
      it 'renders edit template' do
        expect(response).to render_template 'edit'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context "edited by job seeker's case manager" do
      before(:each) do
        sign_in case_manager
        jobseeker.assign_case_manager(case_manager, agency)
        get :edit, id: case_manager.job_seekers.first
      end
      it 'renders edit_by_cm template' do
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'GET #home' do
    let(:jobseeker) { FactoryGirl.create(:job_seeker) }
    before(:each) do
      sign_in jobseeker
      get :home, id: jobseeker
    end

    it 'renders homepage template' do
      expect(response).to render_template 'home'
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
    it 'assigns application_type for pagination' do
      expect(assigns(:application_type)).to eq 'job_seeker'
    end

    it 'returns jobs posted since last login' do
      stub_cruncher_authenticate
      stub_cruncher_job_create

      @newjob = FactoryGirl.create(:job)
      @newjob.assign_attributes(created_at: Time.now)
      @oldjob = FactoryGirl.create(:job)
      @oldjob.update_attributes(created_at: Time.now - 2.weeks)
      jobseeker.assign_attributes(last_sign_in_at: (Time.now - 1.week))
      expect(Job.new_jobs(jobseeker.last_sign_in_at)).to include(@newjob)
      expect(Job.new_jobs(jobseeker.last_sign_in_at)).not_to include(@oldjob)
    end
  end

  describe 'GET #index' do
    let(:admin) { FactoryGirl.create(:agency_admin) }
    before(:each) do
      sign_in admin
      get :index
    end
    it 'renders the index template' do
      expect(response.body).to render_template 'index'
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:jobseeker) { FactoryGirl.create(:job_seeker) }
    before(:each) do
      sign_in jobseeker
      get :show, id: jobseeker
    end
    it 'assigns application_type for pagination' do
      expect(assigns(:application_type)).to eq 'job_seeker'
    end
    it 'it renders the show template' do
      expect(response).to render_template 'show'
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #preview_info' do
    let(:agency) { FactoryGirl.create(:agency) }
    let(:jobseeker) { FactoryGirl.create(:job_seeker) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    before(:each) do
      sign_in job_developer
      jobseeker.assign_job_developer(job_developer, agency)
      xhr :get, :preview_info, id: jobseeker
    end
    it "it renders job seeker's info partial" do
      expect(response).to render_template(partial: '_info')
    end
  end

  describe 'DELETE #destroy' do
    let(:jobseeker) { FactoryGirl.create(:job_seeker) }
    before(:each) do
      sign_in jobseeker
      delete :destroy, id: jobseeker
    end
    it 'sets flash message' do
      expect(flash[:notice]).to eq 'Jobseeker was deleted successfully.'
    end
    it 'returns redirect status' do
      expect(response).to have_http_status(:redirect)
    end
  end
end
