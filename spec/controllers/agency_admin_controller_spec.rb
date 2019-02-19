require 'rails_helper'

RSpec.describe AgencyAdminController, type: :controller do
  let(:agency)        { FactoryBot.create(:agency) }
  let!(:agency_admin) { FactoryBot.create(:agency_admin, agency: agency) }
  let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:job_seeker)    { FactoryBot.create(:job_seeker) }
  let(:job_categories) do
    cats = []
    cats << FactoryBot.create(:job_category, name: 'CAT1') <<
      FactoryBot.create(:job_category, name: 'CAT2') <<
      FactoryBot.create(:job_category, name: 'CAT3')
    cats
  end

  describe 'GET #home and GET #job_properties' do
    it 'routes GET /agency_admin/home/ to agency_admin#home' do
      expect(get: '/agency_admin/home').to route_to(
        controller: 'agency_admin', action: 'home'
      )
    end

    it 'routes GET /agency_admin/job_properties/ to agency_admin#job_properties' do
      expect(get: '/agency_admin/job_properties').to route_to(
        controller: 'agency_admin', action: 'job_properties'
      )
    end

    context 'non agency person attempts access' do
      it 'prevents non agency access' do
        sign_in agency_admin
        agency_admin.update_attribute(:actable_type, nil)
        get :home
        expect(flash[:notice])
          .to eq 'Current agency cannot be determined'
      end
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
      it 'returns success' do
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
      it 'returns success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'XHR GET #home' do
    before(:each) do
      25.times do |_n|
        FactoryBot.create(:agency_person, agency: agency)
        cmp = FactoryBot.build(:company)
        cmp.agencies << agency
        cmp.save
      end
      sign_in agency_admin
      get :home
    end

    it 'renders partial for branches' do
      get :home, params: { branches_page: 2, data_type: 'branches' }, xhr: true
      expect(response).to render_template(partial: 'branches/_branches')
      expect(response).to have_http_status(:success)
    end

    it 'renders partial for people' do
      get :home, params: { people_page: 2, data_type: 'people' }, xhr: true
      expect(response)
        .to render_template(partial: 'agency_people/_agency_people')
      expect(response).to have_http_status(:success)
    end

    it 'renders partial for companies' do
      get :home, params: { companies_page: 2, data_type: 'companies' }, xhr: true
      expect(response).to render_template(partial: 'companies/_companies')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'XHR GET #job_properties' do
    before(:each) do
      25.times do |n|
        FactoryBot.create(:job_category, name: "CAT#{n}")
      end
      sign_in agency_admin
      get :job_properties
    end

    it 'renders partial for job categories' do
      get :job_properties, params: { job_categories_page: 2,
                                     data_type: 'job_categories' },
                           xhr: true
      expect(response).to render_template(partial: '_job_specialties')
      expect(response).to have_http_status(:success)
    end
    it 'renders partial for job skills' do
      get :job_properties, params: { skills_page: 1,
                                     data_type: 'skills' },
                           xhr: true
      expect(response).to render_template(partial: 'shared/_job_skills')
      expect(response).to have_http_status(:success)
    end
    it 'raises data type error' do
      expect do
        get :job_properties, params: { skills_page: 1,
                                       data_type: 'xxxxx' },
                             xhr: true
      end.to raise_error 'Do not recognize data type: xxxxx'
    end
  end

  describe 'Determine from signed-in user:' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
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
    it 'non-admin and non-agency returns nil' do
      sign_in job_seeker
      expect(Agency.this_agency(job_seeker)).to eq nil
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
        expect(flash[:alert])
          .to eq "You are not authorized to administer #{agency.name} agency."
      end
    end

    context '.job_properties' do
      it 'authorizes agency_admin' do
        expect(subject).to_not receive(:user_not_authorized)
        sign_in agency_admin
        expect { get :job_properties }.to_not raise_error
      end
      it 'does not authorize non-admin user' do
        sign_in case_manager
        get :job_properties
        expect(flash[:alert])
          .to eq "You are not authorized to administer #{agency.name} agency."
      end
    end
  end
end
