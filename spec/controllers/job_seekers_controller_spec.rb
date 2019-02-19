require 'rails_helper'
include ServiceStubHelpers::Cruncher

module Helpers
  def assign_role(role)
    let(:agency) { FactoryBot.create(:agency) }
    let(:company) { FactoryBot.create(:company, agencies: [agency]) }
    case role
    when 'job_seeker'
      let(:person) { FactoryBot.create(:job_seeker) }
    when 'owner'
      let(:person) { owner }
    when 'owner_job_developer'
      let(:person) { owner_job_developer }
    when 'owner_case_manager'
      let(:person) { owner_case_manager }
    when 'company_person', 'company_admin', 'company_contact'
      let(:person) { FactoryBot.send(:create, role.to_sym, company: company) }
    when 'agency_person', 'job_developer', 'case_manager', 'agency_admin'
      let(:person) { FactoryBot.send(:create, role.to_sym, agency: agency) }
    else
      let(:person) { nil }
    end
  end

  def assign_role_action(role, action)
    let(:agency) { FactoryBot.create(:agency) }
    let(:company) { FactoryBot.create(:company, agencies: [agency]) }
    let(:status) { FactoryBot.create(:job_seeker_status) }
    let(:valid_attribute) do
      FactoryBot.attributes_for(:job_seeker)
                .merge(FactoryBot.attributes_for(:user))
                .merge(job_seeker_status_id: status.id)
                .merge(address_attributes: FactoryBot.attributes_for(:address,
                                                                     zipcode: '12346'))
    end
    case role
    when 'owner'
      let(:person) { owner }
    when 'agency_person', 'job_developer', 'case_manager', 'agency_admin'
      let(:person) { FactoryBot.send(:create, role.to_sym, agency: agency) }
    else
      let(:person) { nil }
    end

    case action
    when 'create'
      let(:message) do
        'A message with a confirmation and link has been sent to your email address. ' \
        'Please follow the link to activate your account.'
      end
      let(:request) { post :create, params: { job_seeker: valid_attribute } }
    when 'destroy'
      let(:message) { 'Jobseeker was deleted successfully.' }
      let(:request) { delete :destroy, params: { id: owner } }
    else
      let(:message) { nil }
    end
  end
end

RSpec.configure do |c|
  c.extend Helpers
end

RSpec.shared_examples 'unauthorized to js controller' do |role|
  assign_role(role)
  before :each do
    warden.set_user person
    request
  end
  it 'returns http redirect' do
    expect(response).to have_http_status(:redirect)
  end
  it 'sets flash[:alert] message' do
    expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      .or eq('You need to login to perform this action.')
  end
end

RSpec.shared_examples 'unauthorized action (xhr)' do |role|
  assign_role(role)
  before :each do
    warden.set_user person
    request
  end
  it 'returns http unauthorized / forbidden' do
    expect(response).to have_http_status(:unauthorized)
      .or have_http_status(:forbidden)
  end
  it 'returns unauthenticated / unauthorized message' do
    expect(JSON.parse(response.body, symbolize_names: true)[:message])
      .to eq('You need to login to perform this action.')
      .or eq('You are not authorized to perform this action.')
  end
end

RSpec.shared_examples 'authorized to create / destroy job seeker' do |role, action|
  assign_role_action(role, action)
  before :each do
    warden.set_user person
    request
  end
  it 'sets flash[:notice] message' do
    expect(flash[:notice]).to eq message
  end
  it 'returns redirect status' do
    expect(response).to have_http_status(:redirect)
  end
  it 'redirects to root page' do
    expect(response).to redirect_to(root_path)
  end
end

RSpec.shared_examples 'authorized to retrieve data' do |role|
  assign_role(role)
  before :each do
    warden.set_user person
    request
  end
  it 'returns http success' do
    expect(response).to have_http_status(:success)
  end
end

RSpec.describe JobSeekersController, type: :controller do
  describe 'GET #new' do
    let(:request) { get :new }
    context 'visitor' do
      it_behaves_like 'authorized to retrieve data', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'authorized to retrieve data', 'agency_person'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_person'
    end
    it 'renders new template' do
      request
      expect(response).to render_template 'new'
    end
  end

  describe 'POST #create' do
    let(:request) do
      post :create, params: {
        job_seeker: FactoryBot.attributes_for(:job_seeker)
      }
    end
    context 'visitor' do
      it_behaves_like 'authorized to create / destroy job seeker', 'visitor', 'create'
    end
    context 'agency_person' do
      it_behaves_like 'authorized to create / destroy job seeker', 'agency_person',
                      'create'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_person'
    end

    context 'valid attributes' do
      before(:each) do
        js_status = FactoryBot.create(:job_seeker_status)
        ActionMailer::Base.deliveries.clear
        @js_hash = FactoryBot.attributes_for(:job_seeker)
                             .merge(FactoryBot.attributes_for(:user))
                             .merge(job_seeker_status_id: js_status.id)
        @js_hash[:address_attributes] = FactoryBot.attributes_for(:address,
                                                                  zipcode: '54321')
        post :create, params: { job_seeker: @js_hash }
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
        it { is_expected.to have_body_text(/Welcome/) }
        it { is_expected.to have_body_text(/#{@js_hash[:first_name]}/) }
        it { is_expected.to have_body_text(/#{@js_hash[:last_name]}/) }
        it { is_expected.to have_body_text(/You can confirm your account/) }
        it { is_expected.to have_body_text(%r{users\/confirmation\?confirmation}) }
        it { is_expected.to have_subject(/Confirmation instructions/) }
      end
    end

    context 'valid attributes and resume file upload' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload

        ActionMailer::Base.deliveries.clear
        js_status = FactoryBot.create(:job_seeker_status)
        @js_hash = FactoryBot.attributes_for(
          :job_seeker,
          resume: fixture_file_upload('files/Janitor-Resume.doc')
        ).merge(FactoryBot.attributes_for(:user))
                             .merge(job_seeker_status_id: js_status.id)
      end

      it 'saves job seeker' do
        expect { post :create, params: { job_seeker: @js_hash } }
          .to change(JobSeeker, :count).by(+1)
      end
      it 'saves resume record' do
        expect { post :create, params: { job_seeker: @js_hash } }
          .to change(Resume, :count).by(+1)
      end
    end

    context 'invalid attributes' do
      before(:each) do
        @jobseeker = FactoryBot.create(:job_seeker)
        @user = FactoryBot.create(:user)
        @jobseekerstatus = FactoryBot.create(:job_seeker_status)
        @jobseeker.assign_attributes(year_of_birth: '198')
        @user.assign_attributes(first_name: 'John', last_name: 'Smith',
                                phone: '890-789-9087')
        @jobseekerstatus.assign_attributes(description: 'MyText')
        @jobseeker.valid?
        js1_hash = FactoryBot.attributes_for(
          :job_seeker, year_of_birth: '198',
                       resume: fixture_file_upload('files/Janitor-Resume.doc')
        ).merge(FactoryBot.attributes_for(
                  :user, first_name: 'John', last_name: 'Smith', phone: '890-789-9087'
                )).merge(FactoryBot.attributes_for(
                           :job_seeker_status, description: 'MyText'
                         )).merge(FactoryBot.attributes_for(
                                    :address, zipcode: '12345131231231231231236'
                                  ))
        post :create, params: { job_seeker: js1_hash }
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
    let(:agency) { FactoryBot.create(:agency) }
    let(:owner_job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:owner_case_manager) { FactoryBot.create(:case_manager, agency: agency) }
    let(:owner) do
      js = FactoryBot.create(:job_seeker, phone: '123-456-7890')
      js.assign_job_developer(owner_job_developer, agency)
      js.assign_case_manager(owner_case_manager, agency)
      js
    end
    let(:request) { patch :update, params: { id: owner } }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'unauthorized to js controller', 'agency_admin'
      it_behaves_like 'unauthorized to js controller', 'job_developer'
      it_behaves_like 'unauthorized to js controller', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_person'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'owner' do
      let(:js_status) { FactoryBot.create(:job_seeker_status) }
      let(:password) { owner.encrypted_password }
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload
        sign_in owner
      end
      it 'updates email address' do
        patch :update, params: { id: owner, job_seeker: FactoryBot
          .attributes_for(:job_seeker, email: 'test@test.com') }
        expect(flash[:warning])
          .to eq 'Please check your inbox to update your email address'
      end
      context 'successful initial résumé upload' do
        it 'saves the first resume record' do
          expect do
            patch :update, params: {
              id: owner,
              job_seeker: FactoryBot.attributes_for(
                :job_seeker,
                resume: fixture_file_upload('files/Janitor-Resume.doc')
              )
            }
          end.to change(Resume, :count).by(+1)
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
        end
      end
      context 'valid attributes without password change' do
        before(:each) do
          FactoryBot.create(:resume,
                            file_name: 'Janitor-Resume.doc',
                            file: fixture_file_upload('files/Janitor-Resume.doc'),
                            job_seeker: owner)
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(
              :job_seeker,
              year_of_birth: '1980',
              first_name: 'John',
              last_name: 'Smith',
              password: '',
              password_confirmation: '',
              phone: '780-890-8976',
              resume: fixture_file_upload('files/Admin-Assistant-Resume.pdf')
            ).merge(job_seeker_status_id: js_status.id)
                                  .merge(
                                    address_attributes: FactoryBot.attributes_for(
                                      :address, zipcode: '12346'
                                    )
                                  )
          }
          owner.reload
        end
        it 'sets the valid attributes' do
          expect(owner.first_name).to eq 'John'
          expect(owner.last_name).to eq 'Smith'
          expect(owner.year_of_birth).to eq '1980'
          expect(owner.status.id).to eq js_status.id
          expect(owner.address.zipcode).to eq '12346'
          expect(owner.resumes[0].file_name)
            .to eq 'Admin-Assistant-Resume.pdf'
        end
        it 'dont change password' do
          expect(owner.encrypted_password).to eq password
        end
        it 'sets flash message' do
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
        end
        it 'returns redirect status' do
          expect(response).to have_http_status(:redirect)
        end
        it 'redirects to homepage' do
          expect(response).to redirect_to(home_job_seeker_path)
        end
      end
      context 'unsuccessful résumé upload' do
        render_views
        before(:each) do
          FactoryBot.create(:resume,
                            file_name: 'Janitor-Resume.doc',
                            file: fixture_file_upload('files/Janitor-Resume.doc'),
                            job_seeker: owner)
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(
              :job_seeker,
              resume: fixture_file_upload('files/Example Excel File.xls')
            )
          }
          owner.reload
        end
        it 'does not update existing resume' do
          expect(owner.resumes[0].file_name).to eq 'Janitor-Resume.doc'
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
          owner.assign_attributes(year_of_birth: '198')
          owner.valid?
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  year_of_birth: '198',
                                                  resume: '')
          }
        end
        it 'renders edit template' do
          expect(response).to render_template('edit')
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end
    context ' related case manager ' do
      let(:password) { owner.encrypted_password }
      before(:each) do
        sign_in owner_case_manager
      end
      context 'valid attributes' do
        it 'locates the requested @jobseeker' do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker)
          }
          expect(assigns(:jobseeker)).to eq(owner)
        end
        it "changes @jobseeker's attribute" do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  phone: '111-111-1111')
          }
          owner.reload
          expect(owner.phone).to eq('111-111-1111')
        end
        it 'sets flash message and redirects to job seeker show page' do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker)
          }
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
          expect(response).to redirect_to owner
        end
      end
      context 'unauthorized attributes' do
        before(:each) do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  year_of_birth: '1988',
                                                  password: '123345',
                                                  password_confirmation: '123345')
          }
          owner.reload
        end
        it "does not change job seeker's attribute" do
          expect(owner.year_of_birth).to eq('1998')
          expect(owner.encrypted_password).to eq password
        end
      end
      context 'invalid attributes' do
        before(:each) do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  phone: '123')
          }
          owner.reload
        end
        it "does not change job seeker's attribute" do
          expect(owner.phone).to eq('123-456-7890')
        end
        it 're-renders the edit template' do
          expect(response).to render_template('edit')
        end
      end
    end
    context ' related job_developer ' do
      let(:password) { owner.encrypted_password }
      before(:each) do
        sign_in owner_job_developer
      end
      context 'valid attributes' do
        it 'locates the requested @jobseeker' do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker)
          }
          expect(assigns(:jobseeker)).to eq(owner)
        end
        it "changes @jobseeker's attribute" do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  phone: '111-111-1111')
          }
          owner.reload
          expect(owner.phone).to eq('111-111-1111')
        end
        it 'sets flash message and redirects to job seeker show page' do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker)
          }
          expect(flash[:notice]).to eq 'Jobseeker was updated successfully.'
          expect(response).to redirect_to owner
        end
      end
      context 'unauthorized attributes' do
        before(:each) do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  year_of_birth: '1988',
                                                  password: '123345',
                                                  password_confirmation: '123345')
          }
          owner.reload
        end
        it "does not change job seeker's attribute" do
          expect(owner.year_of_birth).to eq('1998')
          expect(owner.encrypted_password).to eq password
        end
      end
      context 'invalid attributes' do
        before(:each) do
          patch :update, params: {
            id: owner,
            job_seeker: FactoryBot.attributes_for(:job_seeker,
                                                  phone: '123')
          }
          owner.reload
        end
        it "does not change job seeker's attribute" do
          expect(owner.phone).to eq('123-456-7890')
        end
        it 're-renders the edit template' do
          expect(response).to render_template('edit')
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:owner_job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:owner_case_manager) { FactoryBot.create(:case_manager, agency: agency) }
    let(:owner) do
      js = FactoryBot.create(:job_seeker)
      js.assign_job_developer(owner_job_developer, agency)
      js.assign_case_manager(owner_case_manager, agency)
      js
    end
    let(:resume) do
      FactoryBot.create(:resume,
                        file_name: 'Janitor-Resume.doc',
                        file: fixture_file_upload('files/Janitor-Resume.doc'),
                        job_seeker: owner)
    end
    let(:request) { get :edit, params: { id: owner } }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'random agency_person' do
      it_behaves_like 'unauthorized to js controller', 'agency_admin'
      it_behaves_like 'unauthorized to js controller', 'job_developer'
      it_behaves_like 'unauthorized to js controller', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_person'
    end
    context 'random job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'related job developer, related case_manager' do
      it_behaves_like 'authorized to retrieve data', 'owner'
      it_behaves_like 'authorized to retrieve data', 'owner_job_developer'
      it_behaves_like 'authorized to retrieve data', 'owner_case_manager'
    end
    context 'owner' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload

        sign_in owner
        request
      end
      it 'assigns jobseeker and current_resume for view' do
        expect(assigns(:jobseeker)).to eq owner
        expect(assigns(:current_resume)).to eq owner.resumes[0]
      end
      it 'renders edit template' do
        expect(response).to render_template 'edit'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #home' do
    let(:owner) { FactoryBot.create(:job_seeker) }
    let(:request) { get :home, params: { id: owner } }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'unauthorized to js controller', 'agency_admin'
      it_behaves_like 'unauthorized to js controller', 'job_developer'
      it_behaves_like 'unauthorized to js controller', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_person'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'owner' do
      before :each do
        sign_in owner
        request
      end
      it 'renders homepage template' do
        expect(response).to render_template 'home'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
      it 'assigns application_type for pagination' do
        expect(assigns(:application_type)).to eq 'job_seeker-default'
      end
      it 'returns jobs posted since last login' do
        stub_cruncher_authenticate
        stub_cruncher_job_create

        @newjob = FactoryBot.create(:job)
        @newjob.assign_attributes(created_at: Time.now)
        @oldjob = FactoryBot.create(:job)
        @oldjob.update_attributes(created_at: Time.now - 2.weeks)
        owner.assign_attributes(last_sign_in_at: (Time.now - 1.week))
        expect(Job.new_jobs(owner.last_sign_in_at)).to include(@newjob)
        expect(Job.new_jobs(owner.last_sign_in_at)).not_to include(@oldjob)
      end
    end
  end

  describe 'GET #index' do
    let(:request) { get :index }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'authorized to retrieve data', 'agency_admin'
      it_behaves_like 'authorized to retrieve data', 'job_developer'
      it_behaves_like 'authorized to retrieve data', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_admin'
      it_behaves_like 'unauthorized to js controller', 'company_contact'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    it 'renders the index template' do
      sign_in FactoryBot.create(:agency_admin)
      request
      expect(response.body).to render_template 'index'
    end
  end

  describe 'GET #show' do
    let(:owner) { FactoryBot.create(:job_seeker) }
    let(:request) { get :show, params: { id: owner } }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'authorized to retrieve data', 'agency_admin'
      it_behaves_like 'authorized to retrieve data', 'job_developer'
      it_behaves_like 'authorized to retrieve data', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'authorized to retrieve data', 'company_admin'
      it_behaves_like 'authorized to retrieve data', 'company_contact'
    end
    context 'random job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'owner' do
      before(:each) do
        sign_in owner
        request
      end
      # the job seeker should not be able to see their show page
      # this information is already available in their home page
      it 'it does not render the show template' do
        expect(response).not_to render_template 'show'
      end
    end
  end

  describe 'GET #preview_info' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:owner_job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:owner_case_manager) { FactoryBot.create(:case_manager, agency: agency) }
    let(:owner) do
      js = FactoryBot.create(:job_seeker)
      js.assign_job_developer(owner_job_developer, agency)
      js.assign_case_manager(owner_case_manager, agency)
      js
    end
    let(:request) { get :preview_info, params: { id: owner }, xhr: true }
    context 'visitor' do
      it_behaves_like 'unauthorized action (xhr)', 'visitor'
    end
    context 'random agency_person' do
      it_behaves_like 'unauthorized action (xhr)', 'agency_admin'
      it_behaves_like 'unauthorized action (xhr)', 'job_developer'
      it_behaves_like 'unauthorized action (xhr)', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized action (xhr)', 'company_person'
    end
    context 'job_seeker' do
      it_behaves_like 'unauthorized action (xhr)', 'job_seeker'
    end
    context 'owner, related case_manager' do
      it_behaves_like 'unauthorized action (xhr)', 'owner'
      it_behaves_like 'unauthorized action (xhr)', 'owner_case_manager'
    end
    context 'related job_developer' do
      it "it renders job seeker's info partial" do
        sign_in owner_job_developer
        request
        expect(response).to render_template(partial: '_info')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:owner) { FactoryBot.create(:job_seeker) }
    let(:request) { delete :destroy, params: { id: owner } }
    context 'visitor' do
      it_behaves_like 'unauthorized to js controller', 'visitor'
    end
    context 'agency_person' do
      it_behaves_like 'authorized to create / destroy job seeker', 'agency_admin',
                      'destroy'
      it_behaves_like 'unauthorized to js controller', 'job_developer'
      it_behaves_like 'unauthorized to js controller', 'case_manager'
    end
    context 'company_person' do
      it_behaves_like 'unauthorized to js controller', 'company_admin'
      it_behaves_like 'unauthorized to js controller', 'company_contact'
    end
    context 'random job_seeker' do
      it_behaves_like 'unauthorized to js controller', 'job_seeker'
    end
    context 'owner' do
      it_behaves_like 'authorized to create / destroy job seeker', 'owner', 'destroy'
    end
  end
  describe 'GET #list_match_jobs' do
    let(:jobseeker) { FactoryBot.create(:job_seeker) }
    let(:company) { FactoryBot.create(:company) }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_upload
      sign_in jobseeker
    end
    context 'User without a resume' do
      before(:each) do
        get :list_match_jobs, params: { id: jobseeker }
      end
      it 'flash message set' do
        expect(flash[:error]).to be_present
      end
      it 'correct content' do
        expect(flash[:error]).to eq('John Doe does not have a resume on file')
      end
      it 'redirects to root' do
        expect(response).to redirect_to(root_path)
      end
    end
    context 'User with a resume' do
      context 'no matches' do
        before(:each) do
          stub_cruncher_no_match_jobs
          FactoryBot.create(:resume,
                            file_name: 'resume.pdf',
                            job_seeker: jobseeker)
          get :list_match_jobs, params: { id: jobseeker }
        end
        it 'no flash message set' do
          expect(flash[:error]).to_not be_present
        end
        it 'empty rating' do
          expect(assigns(:star_rating)).to eq({})
        end
        it 'emtpy list of jobs' do
          expect(assigns(:list_jobs)).to eq([])
        end
      end
      context 'Multiple matches' do
        let!(:job2) do
          FactoryBot.create(:job, id: 2, title: 'Job 2', company: company)
        end
        let!(:job3) do
          FactoryBot.create(:job, id: 3, title: 'Job 3', company: company)
        end
        let!(:job6) do
          FactoryBot.create(:job, id: 6, title: 'Job 6', company: company)
        end
        let!(:job8) do
          FactoryBot.create(:job, id: 8, title: 'Job 8', company: company)
        end
        let!(:job9) do
          FactoryBot.create(:job, id: 9, title: 'Job 9', company: company)
        end
        before(:each) do
          stub_cruncher_match_jobs
          FactoryBot.create(:resume,
                            file_name: 'resume.pdf',
                            job_seeker: jobseeker)
          get :list_match_jobs, params: { id: jobseeker }
        end
        it 'no flash message set' do
          expect(flash[:error]).to_not be_present
        end
        it 'check output of cruncher' do
          expect(assigns(:star_rating))
            .to eq(3 => 4.7, 2 => 3.8, 6 => 3.4, 9 => 2.9, 8 => 2.8)
        end
        it 'list of jobs' do
          expect(assigns(:list_jobs)).to eq([job3, job2, job6, job9, job8])
        end
      end
    end
  end

  describe 'GET download_resume' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_upload
      sign_in company_admin
    end

    let(:company)       { FactoryBot.create(:company) }
    let(:company2)      { FactoryBot.create(:company) }
    let(:job)           { FactoryBot.create(:job, company: company) }
    let(:job2)          { FactoryBot.create(:job, company: company2) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }
    let(:job_seeker2)   { FactoryBot.create(:job_seeker) }
    let!(:company_admin) { FactoryBot.create(:company_admin, company: company) }
    let!(:company_admin2) { FactoryBot.create(:company_admin, company: company2) }
    let(:company_contact) { FactoryBot.create(:company_contact, company: company) }
    let!(:valid_application) do
      FactoryBot.create(:job_application, job: job, job_seeker: job_seeker)
    end
    let!(:valid_application2) do
      FactoryBot.create(:job_application, job: job2, job_seeker: job_seeker2)
    end
    let(:invalid_application) do
      FactoryBot.create(:job_application,
                        job: job, job_seeker: job_seeker2,
                        status: 'accepted')
    end
    let(:agency) { FactoryBot.create(:agency) }
    let(:agency_admin) { FactoryBot.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:case_manager) { FactoryBot.create(:case_manager, agency: agency) }
    let!(:resume) { FactoryBot.create(:resume, job_seeker: job_seeker) }
    let!(:resume2) { FactoryBot.create(:resume, job_seeker: job_seeker2) }

    context 'Successful download' do
      it 'does not raise exception' do
        stub_cruncher_file_download('files/Admin-Assistant-Resume.pdf')
        get :download_resume, params: { id: job_seeker, resume_id: resume }
        expect(response).to_not set_flash
      end
    end
    context 'Error: Unauthorised Download' do
      it 'sets flash message' do
        get :download_resume, params: { id: job_seeker2, resume_id: resume2 }
        expect(flash[:alert]).to eq 'You are not authorized to perform this action.'
      end
    end
    context 'Error: Resume not found in DB' do
      it 'sets flash message' do
        get :download_resume, params: { id: valid_application, resume_id: 999 }
        expect(flash[:alert]).to eq "Couldn't find Resume with 'id'=999"
      end
    end
    context 'Error: Resume not found in Cruncher' do
      it 'sets flash message' do
        stub_cruncher_file_download_notfound
        get :download_resume, params: { id: valid_application, resume_id: resume }
        expect(flash[:alert]).to eq 'Error: Resume not found in Cruncher'
      end
    end
  end
end
