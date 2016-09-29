require 'rails_helper'

RSpec.describe AgencyAdminController, type: :controller do

  let(:agency)        { FactoryGirl.create(:agency) }
  let!(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:job_categories) do
    cats = []
    cats << FactoryGirl.create(:job_category, name: 'CAT1') <<
             FactoryGirl.create(:job_category, name: 'CAT2') <<
             FactoryGirl.create(:job_category, name: 'CAT3')
    cats
  end

  describe "GET #home and GET #job_properties" do

    it 'routes GET /agency_admin/home/ to agency_admin#home' do
      expect(get: '/agency_admin/home').to route_to(
            controller: 'agency_admin', action: 'home')
    end

    it 'routes GET /agency_admin/job_properties/ to agency_admin#job_properties' do
      expect(get: '/agency_admin/job_properties').to route_to(
            controller: 'agency_admin', action: 'job_properties')
    end

    context 'controller actions and helper - home page' do
      before(:each) do
        sign_in agency_admin
        get :home
      end
      it 'assigns agency for view' do
        expect(assigns(:agency)).to eq agency
      end
      it 'assigns agency_admin for view' do
        expect(assigns(:agency_admins)).to eq [agency_admin]
      end
      it 'renders home template' do
        expect(response).to render_template('home')
      end
      it "returns success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'controller actions and helper - job properties page' do
      before(:each) do
        sign_in agency_admin
        get :job_properties
      end
      it 'assigns job_categories for view' do
        expect(assigns(:job_categories)).to eq job_categories
      end
      it 'renders job_categories template' do
         expect(response).to render_template('job_properties')
      end
      it "returns success" do
        expect(response).to have_http_status(:success)
      end
    end

  end

  describe "XHR GET #home" do

    before(:each) do
      25.times do |n|
        FactoryGirl.create(:agency_person, agency: agency)
        cmp = FactoryGirl.build(:company)
        cmp.agencies << agency
        cmp.save
      end
      sign_in agency_admin
      get :home
    end

    it 'renders partial for branches' do
      xhr :get, :home, {branches_page: 2, data_type: 'branches'}
      expect(response).to render_template(partial: 'branches/_branches')
      expect(response).to have_http_status(:success)
    end

    it 'renders partial for people' do
      xhr :get, :home, {people_page: 2, data_type: 'people'}
      expect(response).
          to render_template(partial: 'agency_people/_agency_people')
      expect(response).to have_http_status(:success)
    end

    it 'renders partial for companies' do
      xhr :get, :home, {companies_page: 2, data_type: 'companies'}
      expect(response).to render_template(partial: 'companies/_companies')
      expect(response).to have_http_status(:success)
    end
  end

  describe "XHR GET #job_properties" do

    before(:each) do
      25.times do |n|
        FactoryGirl.create(:job_category, name: "CAT#{n}")
      end
      sign_in agency_admin
      get :job_properties
    end

    it 'renders partial for job categories' do
      xhr :get, :job_properties, {job_categories_page: 2,
                      data_type: 'job_categories'}
      expect(response).to render_template(partial: '_job_specialties')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Determine from signed-in user:' do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'this agency - from agency admin' do
      sign_in agency_admin
      expect(Agency.this_agency(subject.current_user)).to eq agency
    end
    it 'this agency - from case manager' do
      sign_in case_manager
      expect(Agency.this_agency(subject.current_user)).to eq agency
    end
    it 'this agency - from job developer' do
      sign_in job_developer
      expect(Agency.this_agency(subject.current_user)).to eq agency
    end

    it 'agency admin - from agency admin' do
      sign_in agency_admin
      expect(Agency.agency_admins(agency)).to eq [agency_admin]
    end
    it 'agency admin - from case manager' do
      sign_in case_manager
      expect(Agency.agency_admins(agency)).to eq [agency_admin]
    end
    it 'agency admin - from job developer' do
      sign_in job_developer
      expect(Agency.agency_admins(agency)).to eq [agency_admin]
    end

  end

  describe 'action authorization' do
    context '.home' do
      it 'authorizes agency_admin' do
        expect(subject).to_not receive(:user_not_authorized)
        sign_in agency_admin
        get :home
      end
      it 'does not authorize non-admin user' do
        sign_in case_manager
        get :home
        expect(flash[:alert]).
          to eq "You are not authorized to administer #{agency.name} agency."
      end
    end

    context '.job_properties' do
      it 'authorizes agency_admin' do
        expect(subject).to_not receive(:user_not_authorized)
        sign_in agency_admin
        expect {get :job_properties}.to_not raise_error
      end
      it 'does not authorize non-admin user' do
        sign_in case_manager
        get :job_properties
        expect(flash[:alert]).
          to eq "You are not authorized to administer #{agency.name} agency."
      end
    end

  end

end
