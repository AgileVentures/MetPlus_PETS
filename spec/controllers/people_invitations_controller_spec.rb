require 'rails_helper'

RSpec.describe PeopleInvitationsController, type: :controller do
  describe 'GET #new AgencyPerson' do
    context 'valid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:agency_admin)  { FactoryBot.create(:agency_person, agency: agency) }

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in agency_admin
        get :new, params: { person_type: 'AgencyPerson', org_id: agency.id }
      end
      it 'sets session key for person_type' do
        expect(session[:person_type]).to eq 'AgencyPerson'
      end
      it 'sets session key for org_id' do
        expect(session[:org_id]).to eq agency.id.to_s
      end
      it 'renders new_agency_person template' do
        expect(response).to render_template('new_agency_person')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create AgencyPerson' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:agency_admin)  { FactoryBot.create(:agency_admin, agency: agency) }

    it 'sends invitation email' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in agency_admin
      expect { post :create, params: { user: FactoryBot.attributes_for(:user) } }
        .to change(all_emails, :count).by(+1)
    end

    context 'valid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:agency_admin)  { FactoryBot.create(:agency_admin, agency: agency) }
      let(:user_hash)     { FactoryBot.attributes_for(:user) }

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in agency_admin
        post :create, params: { user: user_hash }
      end

      it 'sets flash message' do
        expect(flash[:notice])
          .to eq "An invitation email has been sent to #{user_hash[:email]}."
      end
      it 'redirects as specified' do
        expect(response)
          .to render_template('devise/mailer/invitation_instructions')
      end

      it 'resets session hash values to nil' do
        expect(session[:person_type]).to be nil
        expect(session[:org_id]).to be nil
      end
    end

    context 'reinviting a user' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:agency_admin)  { FactoryBot.create(:agency_person, agency: agency) }
      let!(:user_hash)    { FactoryBot.attributes_for(:user) }

      it 'creates user once upon initial invite' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in agency_admin
        expect { 4.times { post :create, params: { user: user_hash } } }
          .to change(User, :count).by(+1)
      end

      it 'resends invitation to same user' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in agency_admin
        expect { 4.times { post :create, params: { user: user_hash } } }
          .to change(all_emails, :count).by(+4)
      end
    end

    context 'invalid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:agency_admin)  { FactoryBot.create(:agency_person, agency: agency) }
      let(:user_hash) do
        hash = FactoryBot.attributes_for(:user)
        hash[:email] = agency_admin.email
        hash
      end

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in agency_admin
        post :create, params: { user: user_hash }
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #new CompanyPerson' do
    context 'valid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:company)       { FactoryBot.create(:company) }
      let!(:ca_role)      do
        FactoryBot.create(:company_role,
                          role: CompanyRole::ROLE[:CA])
      end
      let(:company_admin) do
        ca = FactoryBot.create(:company_person, company: company)
        ca.company_roles << ca_role
        ca.save
        ca
      end

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in company_admin
        get :new, params: { person_type: 'CompanyPerson', org_id: company.id }
      end
      it 'sets session key for person_type' do
        expect(session[:person_type]).to eq 'CompanyPerson'
      end
      it 'sets session key for org_id' do
        expect(session[:org_id]).to eq company.id.to_s
      end
      it 'renders new_company_person template' do
        expect(response).to render_template('new_company_person')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create CompanyPerson' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:company)       { FactoryBot.create(:company) }
    let!(:ca_role)      do
      FactoryBot.create(:company_role,
                        role: CompanyRole::ROLE[:CA])
    end
    let(:company_admin) do
      ca = FactoryBot.create(:company_person, company: company)
      ca.company_roles << ca_role
      ca.save
      ca
    end

    it 'sends invitation email' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in company_admin
      expect { post :create, params: { user: FactoryBot.attributes_for(:user) } }
        .to change(all_emails, :count).by(+1)
    end

    context 'valid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:company)       { FactoryBot.create(:company) }
      let!(:ca_role)      do
        FactoryBot.create(:company_role,
                          role: CompanyRole::ROLE[:CA])
      end
      let(:company_admin) do
        ca = FactoryBot.create(:company_person, company: company)
        ca.company_roles << ca_role
        ca.save
        ca
      end
      let(:user_hash) { FactoryBot.attributes_for(:user) }

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in company_admin
        post :create, params: { user: user_hash },
                      # following arg is session variables
                      person_type: 'CompanyPerson', org_id: company.id
      end

      it 'sets flash message' do
        expect(flash[:notice])
          .to eq "An invitation email has been sent to #{user_hash[:email]}."
      end
      it 'redirects as specified' do
        expect(response)
          .to render_template('devise/mailer/invitation_instructions')
      end

      it 'resets session hash values to nil' do
        expect(session[:person_type]).to be nil
        expect(session[:org_id]).to be nil
      end
    end

    context 'reinviting a user' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:company)       { FactoryBot.create(:company) }
      let!(:ca_role)      do
        FactoryBot.create(:company_role,
                          role: CompanyRole::ROLE[:CA])
      end
      let(:company_admin) do
        ca = FactoryBot.create(:company_person, company: company)
        ca.company_roles << ca_role
        ca.save
        ca
      end
      let!(:user_hash) { FactoryBot.attributes_for(:user) }

      it 'creates user once upon initial invite' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in company_admin
        expect { 4.times { post :create, params: { user: user_hash } } }
          .to change(User, :count).by(+1)
      end

      it 'resends invitation to same user' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in company_admin
        expect { 4.times { post :create, params: { user: user_hash } } }
          .to change(all_emails, :count).by(+4)
      end
    end

    context 'invalid attributes' do
      let(:agency)        { FactoryBot.create(:agency) }
      let(:company)       { FactoryBot.create(:company) }
      let!(:ca_role)      do
        FactoryBot.create(:company_role,
                          role: CompanyRole::ROLE[:CA])
      end
      let(:company_admin) do
        ca = FactoryBot.create(:company_person, company: company)
        ca.company_roles << ca_role
        ca.save
        ca
      end
      let(:user_hash) do
        hash = FactoryBot.attributes_for(:user)
        hash[:email] = company_admin.email
        hash
      end

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in company_admin
        post :create, params: { user: user_hash },
                      # following arg is session variables
                      person_type: 'CompanyPerson', org_id: company.id
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
