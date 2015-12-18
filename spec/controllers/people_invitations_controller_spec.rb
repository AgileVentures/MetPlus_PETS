require 'rails_helper'

RSpec.describe PeopleInvitationsController, type: :controller do

  describe 'GET #new' do
    
    context 'valid attributes' do
      let(:agency)        { FactoryGirl.create(:agency) }
      let(:agency_admin)  { FactoryGirl.create(:agency_person, agency: agency) }
    
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in agency_admin
        get :new, {person_type: 'AgencyPerson', org_id: agency.id}
      end
      it 'sets session key for person_type' do
        expect(session[:person_type]).to eq 'AgencyPerson'
      end
      it 'sets session key for org_id' do
        expect(session[:org_id]).to eq agency.id.to_s
      end
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe 'POST #create' do
    
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:agency_admin)  { FactoryGirl.create(:agency_person, agency: agency) }
      
    it 'sends invitation email' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in agency_admin
      expect{ post :create, user: FactoryGirl.attributes_for(:user) }.
                    to change(all_emails, :count).by(+1)
    end
    
    context 'valid attributes' do
      
      let(:agency)        { FactoryGirl.create(:agency) }
      let(:agency_admin)  { FactoryGirl.create(:agency_person, agency: agency) }
      let(:user_hash)     { FactoryGirl.attributes_for(:user) }
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in agency_admin
        post :create, { user: user_hash },
                        # following arg is session variables
                      { person_type: 'AgencyPerson', org_id: agency.id }
      end
      
      it 'sets flash message' do
        expect(flash[:notice]).
            to eq "An invitation email has been sent to #{user_hash[:email]}."
      end
      it 'redirect to agency_admin home' do
        expect(response).
            to render_template(@controller.after_invite_path_for(agency_admin))
      end
      
      it 'resets session hash values to nil' do
        expect(session[:person_type]).to be nil
        expect(session[:org_id]).to be nil
      end
    end
    
    context 'invalid attributes' do
      
      let(:agency)        { FactoryGirl.create(:agency) }
      let(:agency_admin)  { FactoryGirl.create(:agency_person, agency: agency) }
      let(:user_hash) do
        $hash = FactoryGirl.attributes_for(:user)
        $hash[:email] = agency_admin.email
        $hash
      end
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in agency_admin
        post :create, { user: user_hash },
                        # following arg is session variables
                      { person_type: 'AgencyPerson', org_id: agency.id }
      end
      
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
    
  end
end
