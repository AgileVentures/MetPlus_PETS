require 'rails_helper'

RSpec.describe AgencyPeopleController, type: :controller do

  describe "GET #show" do
    let(:person)   { FactoryGirl.create(:agency_person) }
    
    before(:each) { get :show, id: person }
    
    it 'assigns @agency_person for view' do
      expect(assigns(:agency_person)).to eq person
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET #edit" do
    let(:person)  { FactoryGirl.create(:agency_person) }
    
    before(:each) { get :edit, id: person }
    
    it 'assigns @agency_person for form' do
      expect(assigns(:agency_person)).to eq person
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "PATCH #update" do
    let(:aa_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA]) }
    
    let(:agency)  { FactoryGirl.create(:agency) }
    
    let(:aa_person) do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << aa_role
      $person.save
      $person
    end
    
    context 'valid attributes' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = [aa_role.id.to_s]
        patch :update, id: aa_person,
            agency_person: person_hash
      end
      it 'assigns @agency_person for updating' do
        expect(assigns(:agency_person)).to eq aa_person
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq "Agency person was successfully updated."
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to branch #show view' do
        expect(response).to redirect_to(agency_person_path(aa_person))
      end
    end
      
    context 'remove admin role for sole agency admin' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = []
        patch :update, id: aa_person, agency_person: person_hash
      end
        
      it 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).
                to eq ["Agency admin cannot be unset for sole agency admin."]
      end
      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe "POST #create" do
    
    let(:agency)   { FactoryGirl.create(:agency) }
    let(:person)   { FactoryGirl.build(:agency_person, agency: agency) }
    let(:person2)  { FactoryGirl.build(:agency_person, agency: agency) }
    
    context 'valid attributes' do
      before(:each) do
        post :create, agency_id: agency, 
                      agency_person: person.attributes.merge(person.user.attributes)
      end
      xit 'assigns @agency for person association' do
        expect(assigns(:agency)).to eq agency
      end
      xit 'sets flash message' do
        expect(flash[:notice]).to eq "Person was successfully created."
      end
      xit "returns redirect status" do
        expect(response).to have_http_status(:redirect)
      end
      xit 'redirects to agency_admin home' do
        expect(response).to redirect_to(agency_admin_home_path)
      end
    end
    
    context 'invalid attributes' do
      before(:each) do
        post :create, agency_id: agency, 
                      agency_person: person2.attributes.merge(person1.user.attributes)
      end
      xit 'assigns @agency for person association' do
        expect(assigns(:agency)).to eq agency
      end
      xit 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).
                 to eq person2.errors.full_messages
      end
      xit 'renders new template' do
        expect(response).to render_template('new')
      end
      xit "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #new" do
    
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:agency_admin)  { FactoryGirl.create(:agency_person, agency: agency) }
    
    before(:each) do
      sign_in agency_admin
      get :new, agency_id: agency
    end
    xit 'assigns @agency for person creation' do
      expect(assigns(:agency)).to eq agency
    end
    xit "returns http success" do
      get :new, agency_id: agency
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #destroy" do
    xit "returns http success" do
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end

end
