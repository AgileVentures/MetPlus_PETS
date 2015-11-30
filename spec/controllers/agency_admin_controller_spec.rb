require 'rails_helper'

RSpec.describe AgencyAdminController, type: :controller do

  describe "GET #home" do
    it 'routes GET /admin/agency_home/ to agency_admin#home' do
      expect(get: '/admin/agency_admin/home').to route_to(
            controller: 'agency_admin', action: 'home')
    end
    context 'controller actions and helper' do
      before(:each) do
        @agency = FactoryGirl.create(:agency)
        @agency_admin = FactoryGirl.build(:agency_person, agency: @agency)
        @agency_admin.agency_roles << 
              FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
        @agency_admin.save!
        sign_in @agency_admin
        get :home
      end
      it 'assigns @agency for view' do
        expect(assigns(:agency)).to eq @agency
      end
      it 'assigns @agency_admin for view' do
        expect(assigns(:agency_admin)).to eq @agency_admin
      end
      it 'renders home template' do
        expect(response).to render_template('home')
      end
      it "returns success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe 'Determine from signed-in user:' do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @agency = FactoryGirl.create(:agency)
      @agency_admin_role = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:AA])
      @case_manager_role   = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:CM])
      @job_developer_role = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:JD])
      
      @agency_admin = FactoryGirl.build(:agency_person, agency: @agency)
      @agency_admin.agency_roles << @agency_admin_role
      @agency_admin.save!
      
      @case_manager = FactoryGirl.build(:agency_person, agency: @agency)
      @case_manager.agency_roles << @case_manager_role
      @case_manager.save!
      
      @job_developer = FactoryGirl.build(:agency_person, agency: @agency)
      @job_developer.agency_roles << @job_developer_role
      @job_developer.save!
    end
    
    it 'this agency - from agency admin' do
      sign_in @agency_admin
      expect(Agency.this_agency(subject.current_user)).to eq @agency
    end
    it 'this agency - from case manager' do
      sign_in @case_manager
      expect(Agency.this_agency(subject.current_user)).to eq @agency
    end
    it 'this agency - from job developer' do
      sign_in @job_developer
      expect(Agency.this_agency(subject.current_user)).to eq @agency
    end
    
    it 'agency manager - from agency admin' do
      sign_in @agency_admin
      expect(Agency.agency_admin(subject.current_user)).to eq @agency_admin
    end
    it 'agency manager - from case manager' do
      sign_in @case_manager
      expect(Agency.agency_admin(subject.current_user)).to eq @agency_admin
    end
    it 'agency manager - from job developer' do
      sign_in @job_developer
      expect(Agency.agency_admin(subject.current_user)).to eq @agency_admin
    end

  end

end
