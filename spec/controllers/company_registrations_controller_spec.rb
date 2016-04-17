require 'rails_helper'

RSpec.describe CompanyRegistrationsController, type: :controller do

  describe "GET #show" do
    let(:company_person) do
      $cp = FactoryGirl.create(:company_person)
      $cp.company_roles << FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])
      $cp.save
      $cp
    end

    let!(:company) do
      $comp = FactoryGirl.build(:company)
      $comp.company_people << company_person
      $comp.save
      $comp
    end

    before(:each) do
      get :show, id: company
    end
    it 'assigns @company for view' do
      expect(assigns(:company)).to eq company
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    let(:company_person) do
      $cp = FactoryGirl.create(:company_person)
      $cp.company_roles << FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])
      $cp.save
      $cp
    end
    let!(:company) do
      $comp = FactoryGirl.build(:company)
      $comp.company_people << company_person
      $comp.save
      $comp
    end

    before(:each) do
      delete :destroy, id: company
    end
    it 'sets flash message' do
      expect(flash[:notice]).
          to eq "Registration for '#{company.name}' deleted."
    end
    it "returns redirect status" do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'DELETE registration also deletes associated objects' do
    let(:company_person) do
      $cp = FactoryGirl.create(:company_person)
      $cp.company_roles << FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])
      $cp.save
      $cp
    end
    let(:address1) { FactoryGirl.create(:address) }
    let(:address2) { FactoryGirl.create(:address, city: 'Detroit') }
    let!(:company) do
      $comp = FactoryGirl.build(:company)
      $comp.company_people << company_person
      $comp.addresses << address1 << address2
      $comp.save
      $comp
    end
    it ' delete company person(s)' do
      expect { delete :destroy, id: company }.
          to change(CompanyPerson, :count).by(-1)
    end
    it ' delete company address(s)' do
      expect { delete :destroy, id: company }.
          to change(Address, :count).by(-2)
    end
  end

  describe "POST #create" do

    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user)]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end

    let!(:company_role) { FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])}

    before(:each) do
      # need to create agency people to receive 'company registered'
      # event email (see models/Event.rb)
      3.times do |n|
        FactoryGirl.create(:agency_person, agency: agency)
      end
    end

    context 'valid attributes' do
      before(:each) do
        post :create, company: registration_params
      end
      it "sets User 'approved' to false" do
        expect(assigns(:company).company_people[0].user.approved).to be false
      end
      it "sets company status to Pending" do
        expect(assigns(:company).status).
                            to eq Company::STATUS[:PND]
      end
      it "sets company person status to Pending" do
        expect(assigns(:company).company_people[0].status).
                            to eq CompanyPerson::STATUS[:PND]
      end
      it 'sets flash message' do
        expect(flash[:notice]).to match "Thank you for your registration request."
      end
      it 'renders confirmation view' do
        expect(response).to render_template(:confirmation)
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    it 'sends registration-pending email' do
      # one email is sent to company registrant,
      # one email is sent to all agency people
      expect { post :create, company: registration_params }.
                    to change(all_emails, :count).by(+2)
    end

    context 'invalid attributes' do
      before(:each) do
        registration_params[:name] = nil
        registration_params[:phone] = '222-333-12345'
        post :create, company: registration_params
      end
      it 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).
            to match_array ["Name can't be blank", "Phone incorrect format"]
      end
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #approve" do
    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user)]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end

    # controller :create action requires a 'CA' role to be present in the DB
    let!(:company_role) { FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])}

    before(:each) do
      3.times do |n|
        FactoryGirl.create(:agency_person, agency: agency)
      end
      post :create, company: registration_params
    end

    it 'sends registration-approved and account-confirm emails' do
      expect { patch :approve,
          id: Company.find_by_name(registration_params[:name]) }.
                    to change(all_emails, :count).by(+2)
    end
    context 'after approval' do
      before(:each) do
        patch :approve, id: Company.find_by_name(registration_params[:name])
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq "Company contact has been notified of registration approval."
      end
      it "returns redirect status" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PATCH #deny" do
    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user)]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end

    # controller :create action requires a 'CA' role to be present in the DB
    let!(:company_role) { FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])}

    before(:each) do
      3.times do |n|
        FactoryGirl.create(:agency_person, agency: agency)
      end
      post :create, company: registration_params
    end

    it 'sends registration-denied email' do
      expect { xhr :patch, :deny,
          id: Company.find_by_name(registration_params[:name]) }.
                    to change(all_emails, :count).by(+1)
    end
    context 'after denial' do
      before(:each) do
        xhr :patch, :deny, id: Company.find_by_name(registration_params[:name])
      end
      it "returns success status" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #update" do
    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user, :password => 'testing1234', :password_confirmation => 'testing1234')]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end
    let!(:prior_name) { registration_params[:name] }

    let!(:company_role) { FactoryGirl.create(:company_role,
                                role: CompanyRole::ROLE[:CA])}

    before(:each) do
      3.times do |n|
        FactoryGirl.create(:agency_person, agency: agency)
      end
      post :create, company: registration_params
    end

    it 'updates person and address but does not add person or address' do
      # Change registration data for update
      company = Company.find_by_name(prior_name)

      registration_params = FactoryGirl.attributes_for(:company,
                                      name: 'Sprockets Corporation')

      registration_params[:company_people_attributes] =
                {'0' => FactoryGirl.attributes_for(:user,
                    first_name: 'Fred', last_name: 'Flintstone')}

      registration_params[:company_people_attributes]['0'][:id] =
                    company.company_people[0].id

      registration_params[:addresses_attributes] =
                {'0' => FactoryGirl.attributes_for(:address,
                    city: 'Boston')}
      registration_params[:addresses_attributes]['0'][:id] =
                    company.addresses[0].id
      expect { patch :update, company: registration_params,
          id: company.id }.
                    to_not change(CompanyPerson, :count)
      expect { patch :update, company: registration_params,
          id: company.id }.
                    to_not change(Address, :count)

    end

    xit 'update company person without password change' do
      # Change registration data for update
      company = Company.find_by_name(prior_name)

      registration_params = FactoryGirl.attributes_for(:company,
                                                       name: 'Sprockets Corporation')

      registration_params[:company_people_attributes] =
          {'0' => FactoryGirl.attributes_for(:user,
                                             first_name: 'Fred', last_name: 'Flintstone',
                                              password: '', password_confirmation: '')}
      registration_params[:company_people_attributes]['0'][:id] =
          company.company_people[0].id

      registration_params[:addresses_attributes] =
          {'0' => FactoryGirl.attributes_for(:address,
                                             city: 'Boston')}
      registration_params[:addresses_attributes]['0'][:id] =
          company.addresses[0].id


      password = company.company_people[0].encrypted_password

      expect { patch :update, company: registration_params,
                     id: company.id }.
          to_not change(CompanyPerson, :count)
      expect { patch :update, company: registration_params,
                     id: company.id }.
          to_not change(Address, :count)

      company.reload

      expect(company.company_people[0].first_name).to eq('Fred')
      expect(company.company_people[0].encrypted_password).to eq(password)

    end
  end

end
