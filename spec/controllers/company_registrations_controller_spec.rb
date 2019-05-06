require 'rails_helper'

RSpec.shared_examples 'authorized show request' do
  before do
    # Use `warden.set_user user` instead of `sign_in user` cause the latter
    # doesn't set pets_user for some weird reason
    warden.set_user user
    request
  end

  it 'assigns @company for view' do
    expect(assigns(:company)).to eq company
  end
  it 'renders show template' do
    expect(response).to render_template(:show)
  end
  it 'returns http success' do
    expect(response).to have_http_status(:success)
  end
end

RSpec.shared_examples 'unauthorized requests' do
  context 'unauthenticated access' do
    it_behaves_like 'unauthenticated request'
  end

  context 'unauthorized access' do
    context 'agency admin not associated with the company' do
      it_behaves_like 'unauthorized request' do
        let(:user) { metplus_admin }
      end
    end

    context 'unauthorized agency people' do
      it_behaves_like 'unauthorized request' do
        let(:user) { cm }
      end
      it_behaves_like 'unauthorized request' do
        let(:user) { jd }
      end
    end

    context 'company people' do
      it_behaves_like 'unauthorized request' do
        let(:user) { cc }
      end
      it_behaves_like 'unauthorized request' do
        let(:user) { company_admin }
      end
    end

    context 'Job Seeker' do
      it_behaves_like 'unauthorized request' do
        let(:user) { js }
      end
    end
  end
end

RSpec.shared_examples 'unauthorized XHR requests' do
  context 'unauthenticated access' do
    it_behaves_like 'unauthenticated XHR request'
  end

  context 'unauthorized access' do
    context 'agency admin not associated with the company' do
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { metplus_admin }
      end
    end

    context 'unauthorized agency people' do
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { cm }
      end
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { jd }
      end
    end

    context 'company people' do
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { cc }
      end
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { company_admin }
      end
    end

    context 'Job Seeker' do
      it_behaves_like 'unauthorized XHR request' do
        let(:user) { js }
      end
    end
  end
end

RSpec.describe CompanyRegistrationsController, type: :controller do
  let!(:agency)          { FactoryBot.create(:agency) }
  let!(:agency_admin)    { FactoryBot.create(:agency_admin, agency: agency) }

  let(:metplus)          { FactoryBot.create(:agency, name: 'Metplus') }
  let(:metplus_admin)    { FactoryBot.create(:agency_admin, agency: metplus) }

  let!(:company) { FactoryBot.create(:company, agencies: [agency]) }
  let(:comp_bayer) do
    FactoryBot.create(:company,
                      name: 'Bayer-Raynor',
                      agencies: [metplus])
  end
  let!(:company_admin) { FactoryBot.create(:first_company_admin, company: company) }
  let(:bayer_admin) { FactoryBot.create(:company_admin, company: comp_bayer) }

  let(:jd) { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm) { FactoryBot.create(:case_manager, agency: agency) }
  let(:cc) { FactoryBot.create(:company_contact) }
  let(:js) { FactoryBot.create(:job_seeker) }

  before(:each) do
    allow(Pusher).to receive(:trigger) # stub and spy on 'Pusher'
  end

  describe 'GET #show' do
    let(:request) { get(:show, params: { id: company }) }
    context 'authorized access' do
      context 'agency admin' do
        it_behaves_like 'authorized show request' do
          let(:user) { agency_admin }
        end
      end

      context 'company admin' do
        it_behaves_like 'authorized show request' do
          let(:user) { company_admin }
        end
      end
    end

    context 'unauthenticated access' do
      it_behaves_like 'unauthenticated request'
    end

    context 'unauthorized access' do
      context 'agency admin not associated with the company' do
        it_behaves_like 'unauthorized request' do
          let(:user) { metplus_admin }
        end
      end

      context 'company admin not associated with the company' do
        it_behaves_like 'unauthorized request' do
          let(:user) { metplus_admin }
        end
      end

      context 'unauthorized agency people' do
        it_behaves_like 'unauthorized request' do
          let(:user) { cm }
        end
        it_behaves_like 'unauthorized request' do
          let(:user) { jd }
        end
      end

      context 'company contact' do
        it_behaves_like 'unauthorized request' do
          let(:user) { cc }
        end
      end

      context 'Job Seeker' do
        it_behaves_like 'unauthorized request' do
          let(:user) { js }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:request) { delete :destroy, params: { id: company } }
    context 'authorized access' do
      before do
        sign_in agency_admin
        request
      end
      it 'sets flash message' do
        expect(flash[:notice])
          .to eq "Registration for '#{company.name}' deleted."
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'unauthorized access' do
      it_behaves_like 'unauthorized requests'
    end
  end

  describe 'DELETE registration also deletes associated objects' do
    let(:address1) { FactoryBot.create(:address) }
    let(:address2) { FactoryBot.create(:address, city: 'Detroit') }
    let!(:test_company) do
      comp = FactoryBot.build(:company, agencies: [agency])
      comp.company_people << company_admin
      comp.addresses << address1 << address2
      comp.save
      comp
    end
    let(:request) { delete :destroy, params: { id: test_company } }

    context 'authorized access' do
      before(:each) do
        sign_in agency_admin
      end

      it 'delete company person(s)' do
        expect { request }.to change(CompanyPerson, :count).by(-1)
      end
      it 'delete company address(s)' do
        expect { request }.to change(Address, :count).by(-2)
      end
    end

    context 'unauthorized access' do
      it_behaves_like 'unauthorized requests'
    end
  end

  describe 'POST #create' do
    let!(:agency) { FactoryBot.create(:agency) }
    let!(:registration_params) do
      params = FactoryBot.attributes_for(:company)
      params[:company_people_attributes] = [FactoryBot.attributes_for(:user)]
      params[:addresses_attributes] =
        [FactoryBot.attributes_for(:address),
         FactoryBot.attributes_for(:address)]
      params
    end
    let!(:company_role) do
      FactoryBot.create(:company_role,
                        role: CompanyRole::ROLE[:CA])
    end

    before(:each) do
      # need to create agency people to receive 'company registered'
      # event email (see models/Event.rb)
      3.times do
        FactoryBot.create(:agency_person, agency: agency)
      end
    end

    context 'valid attributes' do
      before(:each) do
        post :create, params: { company: registration_params }
      end

      it 'sets User approved to false' do
        expect(assigns(:company).company_people[0].user.approved).to be false
      end

      it 'sets User roles to CC and CA' do
        expect(assigns(:company).company_people[0].company_roles[0, 2]
          .map { |x| x[:role] })
          .to contain_exactly 'Company Contact', 'Company Admin'
      end

      it 'sets company status to Pending' do
        expect(assigns(:company).pending_registration?).to be true
      end

      it 'sets company person status to Pending' do
        expect(assigns(:company).company_people[0].status)
          .to eq 'company_pending'
      end

      it 'sets job_email on the model' do
        expect(Company.find_by_job_email(registration_params[:job_email]))
          .not_to be nil
      end

      it 'creates associated addresses' do
        expect(assigns(:company).addresses.count).to eq 2
      end

      it 'sets flash message' do
        expect(flash[:notice])
          .to match 'Thank you for your registration request.'
      end

      it 'renders confirmation view' do
        expect(response).to render_template(:confirmation)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    it 'sends registration-pending email' do
      # one email is sent to company registrant,
      # one email is sent to all agency people
      expect { post :create, params: { company: registration_params } }
        .to have_enqueued_job(CompanyMailerJob).and have_enqueued_job(NotifyEmailJob)
    end

    context 'invalid attributes' do
      render_views

      before(:each) do
        registration_params[:name] = nil
        registration_params[:phone] = '222-333-12345'
        post :create, params: { company: registration_params }
      end

      it 'assigns model errors' do
        expect(assigns(:company).errors.full_messages)
          .to match_array ["Name can't be blank", 'Phone incorrect format']
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'renders partial for errors' do
        expect(response).to render_template(partial: 'shared/_error_messages')
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PATCH #approve' do
    let!(:registration_params) do
      params = FactoryBot.attributes_for(:company)
      params[:company_people_attributes] = [FactoryBot.attributes_for(:user)]
      params[:addresses_attributes] = [FactoryBot.attributes_for(:address)]
      params
    end

    # controller :create action requires a 'CA' role to be present in the DB
    let!(:company_role) do
      FactoryBot.create(:company_role,
                        role: CompanyRole::ROLE[:CA])
    end
    let(:request) do
      patch :approve, params: { id: Company.last }
    end

    context 'authorized access' do
      let(:use_case_mock) { double(Companies::ApproveCompanyRegistration) }
      before(:each) do
        3.times do
          FactoryBot.create(:agency_person, agency: agency)
        end
        sign_in agency_admin
        allow(Companies::ApproveCompanyRegistration)
          .to receive(:new).and_return(use_case_mock)
        allow(use_case_mock)
          .to receive(:call)

        post :create, params: { company: registration_params }
      end

      context 'after approval' do
        before(:each) do
          request
        end

        it 'call the registration use case' do
          expect(use_case_mock).to have_received(:call)
            .with(Company.last)
        end

        it 'sets flash message' do
          expect(flash[:notice])
            .to eq 'Company contact has been notified of registration approval.'
        end

        it 'returns redirect status' do
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'unauthorized access' do
      it_behaves_like 'unauthorized requests'
    end
  end

  describe 'PATCH #deny' do
    let!(:registration_params) do
      params = FactoryBot.attributes_for(:company)
      params[:company_people_attributes] = [FactoryBot.attributes_for(:user)]
      params[:addresses_attributes] = [FactoryBot.attributes_for(:address)]
      params
    end

    let(:use_case_mock) { double(Companies::DenyCompanyRegistration) }

    # controller :create action requires a 'CA' role to be present in the DB
    let!(:company_role) do
      FactoryBot.create(:company_role,
                        role: CompanyRole::ROLE[:CA])
    end
    let(:request) do
      patch :deny, params: { id: Company.last, email_text: 'reason of denial' }, xhr: true
    end

    context 'authorized access' do
      before(:each) do
        3.times do
          FactoryBot.create(:agency_person, agency: agency)
        end

        allow(Companies::DenyCompanyRegistration)
          .to receive(:new).and_return(use_case_mock)
        allow(use_case_mock)
          .to receive(:call)
        post :create, params: { company: registration_params }
        sign_in agency_admin
      end

      context 'after denial' do
        before(:each) do
          request
        end

        it 'call the registration use case' do
          expect(use_case_mock).to have_received(:call)
            .with(Company.last, 'reason of denial')
        end

        it 'returns success status' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'unauthorized access' do
      it_behaves_like 'unauthorized XHR requests'
    end
  end

  describe 'PATCH #update' do
    let!(:registration_params) do
      params = FactoryBot.attributes_for(:company, name: 'Bayer')
      params[:company_people_attributes] =
        { '0' =>
            FactoryBot.attributes_for(:user,
                                      password: 'testing1234',
                                      password_confirmation: 'testing1234') }
      params[:addresses_attributes] =
        { '0' => FactoryBot.attributes_for(:address),
          '1' => FactoryBot.attributes_for(:address) }
      params
    end
    let!(:prior_name) { registration_params[:name] }
    let!(:company_role) do
      FactoryBot.create(:company_role,
                        role: CompanyRole::ROLE[:CA])
    end
    let(:previous_parameters) do
      company = Company.find_by_name(prior_name)
      params = FactoryBot.attributes_for(:company,
                                         name: 'Sprockets Corporation')
      params[:company_people_attributes] =
        { '0' => FactoryBot.attributes_for(:user,
                                           first_name: 'Fred',
                                           last_name: 'Flintstone',
                                           password: '',
                                           password_confirmation: '') }
      params[:company_people_attributes]['0'][:id] =
        company.company_people[0].id
      params[:addresses_attributes] =
        { '0' => FactoryBot.attributes_for(:address,
                                           city: 'Boston') }
      params[:addresses_attributes]['0'][:id] =
        company.addresses[0].id
      params
    end
    let(:company_id) { Company.find_by_name(prior_name).id }
    let(:request) do
      patch :update,
            params: {
              company: registration_params,
              id: Company.last.id
            }
    end

    context 'authorized access' do
      before(:each) do
        3.times do
          FactoryBot.create(:agency_person, agency: agency)
        end
        post :create, params: { company: registration_params }
        sign_in agency_admin
      end

      it 'updates person and address but does not add person or address' do
        # Change registration data for update
        company = Company.find_by_name(prior_name)

        registration_params =
          FactoryBot.attributes_for(:company,
                                    name: 'Sprockets Corporation',
                                    job_email: 'jobs@sprockets.org')

        registration_params[:company_people_attributes] =
          { '0' => FactoryBot.attributes_for(:user,
                                             first_name: 'Fred',
                                             last_name: 'Flintstone') }

        registration_params[:company_people_attributes]['0'][:id] =
          company.company_people[0].id

        registration_params[:addresses_attributes] =
          { '0' => FactoryBot.attributes_for(:address,
                                             city: 'Boston') }
        registration_params[:addresses_attributes]['0'][:id] =
          company.addresses[0].id
        expect do
          patch :update,
                params: {
                  company: registration_params,
                  id: company.id
                }
        end
          .to_not change(CompanyPerson, :count)
        expect do
          patch :update,
                params: {
                  company: registration_params,
                  id: company.id
                }
        end
          .to_not change(Address, :count)

        company.reload
        expect(company.job_email).to eq('jobs@sprockets.org')
      end

      it 'deletes company address' do
        company = Company.find_by_name(prior_name)
        registration_params[:addresses_attributes]['0']['_destroy'] = true
        registration_params[:addresses_attributes]['0']['id'] =
          company.addresses.first.id
        registration_params[:addresses_attributes]['1']['id'] =
          company.addresses.second.id
        registration_params[:company_people_attributes] =
          { '0' => FactoryBot.attributes_for(:user,
                                             first_name: 'Fred',
                                             last_name: 'Flintstone') }
        request
        company.reload
        expect(company.addresses.count).to eq 1
      end

      it 'update company person without password change' do
        # Change registration data for update
        company = Company.find_by_name(prior_name)

        registration_params =
          FactoryBot.attributes_for(:company,
                                    name: 'Sprockets Corporation')
        registration_params[:company_people_attributes] =
          { '0' => FactoryBot.attributes_for(:user,
                                             first_name: 'Fred',
                                             last_name: 'Flintstone',
                                             password: '',
                                             password_confirmation: '') }
        registration_params[:company_people_attributes]['0'][:id] =
          company.company_people[0].id

        registration_params[:addresses_attributes] =
          { '0' => FactoryBot.attributes_for(:address,
                                             city: 'Boston') }
        registration_params[:addresses_attributes]['0'][:id] =
          company.addresses[0].id

        password = company.company_people[0].encrypted_password

        expect do
          patch :update,
                params: {
                  company: registration_params,
                  id: company.id
                }
        end
          .to_not change(CompanyPerson, :count)
        expect do
          patch :update,
                params: {
                  company: registration_params,
                  id: company.id
                }
        end
          .to_not change(Address, :count)

        company.reload
        company.company_people[0].reload

        expect(company.company_people[0].first_name).to eq('Fred')
        expect(company.company_people[0].encrypted_password).to eq(password)
      end

      describe 'job email field' do
        it 'cannot be set to empty' do
          previous_parameters[:job_email] = ''
          patch :update,
                params: {
                  company: previous_parameters,
                  id: company_id
                }
          company = Company.find company_id
          expect(company.job_email).to eq registration_params[:job_email]
        end

        it 'can be changed to another valid address' do
          previous_parameters[:job_email] = 'jobs@real.com'
          patch :update,
                params: {
                  company: previous_parameters,
                  id: company_id
                }
          company = Company.find company_id
          expect(company.job_email).to eq 'jobs@real.com'
        end
      end
    end

    context 'unauthorized access' do
      it_behaves_like 'unauthorized requests'
    end
  end
end
