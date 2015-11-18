require 'rails_helper'
include Devise::TestHelpers

RSpec.describe AgencyAdminController, type: :controller do

  context 'Routing' do
    it 'routes GET /agency_admin/home to agency_admin#home' do
      expect(get: '/agency_admin/home').to route_to(
            controller: 'agency_admin', action: 'home')
    end
  end
  
  describe 'Determine from signed-in user:' do
    before(:each) do
      @agency = FactoryGirl.create(:agency)
      @manager_role = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:AM])
      @admin_role   = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:AA])
      @job_developer_role = FactoryGirl.create(:agency_role,
                              role: AgencyRole::ROLE[:JD])
      
      @agency_manager = FactoryGirl.build(:agency_person, agency: @agency)
      @agency_manager.agency_roles << @manager_role
      @agency_manager.save!
      
      @agency_admin = FactoryGirl.build(:agency_person, agency: @agency)
      @agency_admin.agency_roles << @admin_role
      @agency_admin.save!
      
      @job_developer = FactoryGirl.build(:agency_person, agency: @agency)
      @job_developer.agency_roles << @job_developer_role
      @job_developer.save!
    end
    
    it 'this agency - from agency manager' do
      sign_in @agency_manager
      expect(Agency.this_agency(@agency_manager)).to eq @agency
    end
    it 'this agency - from agency admin' do
      sign_in @agency_admin
      expect(Agency.this_agency(@agency_admin)).to eq @agency
    end
    it 'this agency - from job developer' do
      sign_in @job_developer
      expect(Agency.this_agency(@job_developer)).to eq @agency
    end
    
    it 'agency manager - from agency manager' do
      sign_in @agency_manager
      expect(Agency.agency_manager(@agency_manager)).to eq @agency_manager
    end
    it 'agency manager - from agency admin' do
      sign_in @agency_admin
      expect(Agency.agency_manager(@agency_admin)).to eq @agency_manager
    end
    it 'agency manager - from job developer' do
      sign_in @job_developer
      expect(Agency.agency_manager(@job_developer)).to eq @agency_manager
    end
    
    it 'agency admin - from agency manager' do
      sign_in @agency_manager
      expect(Agency.agency_admin(@agency_manager)).to eq @agency_admin
    end
    it 'agency admin - from agency admin' do
      sign_in @agency_admin
      expect(Agency.agency_admin(@agency_admin)).to eq @agency_admin
    end
    it 'agency admin - from job developer' do
      sign_in @job_developer
      expect(Agency.agency_admin(@job_developer)).to eq @agency_admin
    end
  end

end
