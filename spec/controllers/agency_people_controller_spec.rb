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
    let!(:jd_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD]) }
    let!(:cm_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM]) }

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
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = []
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
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = []
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

  describe "GET #destroy" do

    let(:person) { FactoryGirl.create(:agency_person) }

    before(:each) do
      get :destroy, id: person.id
    end

    it 'sets flash message' do
      expect(flash[:notice]).
        to eq "Person '#{person.full_name(last_name_first: false)}' deleted."
    end

    it "returns http success" do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #edit_profile" do
    let(:person)  { FactoryGirl.create(:agency_person) }

    before(:each) { get :edit_profile, id: person }

    it 'assigns @agency_person for form' do
      expect(assigns(:agency_person)).to eq person
    end
    it 'renders edit_profile template' do
      expect(response).to render_template('edit_profile')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update_profile" do

    context "valid attributes" do
      before(:each) do
        @agency_person = FactoryGirl.build(:agency_person)
#        @agency_person.company_roles <<
#            FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])
        @agency_person.save
        patch :update_profile, id: @agency_person, agency_person: FactoryGirl.attributes_for(:user)

      end

      it 'sets flash message' do
         expect(flash[:notice]).to eq "Your profile was updated successfully."
      end
      it 'returns redirect status' do
         expect(response).to have_http_status(:redirect)
      end
      it 'redirects to mainpage' do
         expect(response).to redirect_to(root_path)
      end
     end
     context "valid attributes without password change" do
       before(:each) do
         @agency_person =  FactoryGirl.build(:agency_person)
         @user =  FactoryGirl.create(:user)
#         @agency_person.company_roles <<
#             FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])
         @agency_person.save
         @agency_person.valid?
         patch :update_profile, agency_person:FactoryGirl.attributes_for(:agency_person, password: nil, password_confirmation: nil).
           merge(FactoryGirl.attributes_for(:user, first_name:'John',last_name:'Smith',phone:'780-890-8976')),
           id:@agency_person
         @agency_person.reload
         @user.reload

       end
      it 'sets a role' do
        expect(@agency_person.title).to eq ("Line Manager")
      end
      it 'sets a branch' do
        expect(@agency_person.branch).to eq ("Line Manager")
      end
      it 'sets a firstname' do
         expect(@agency_person.first_name).to eq ("John")
      end
      it 'sets a lastname' do
         expect(@agency_person.last_name).to eq ("Smith")
      end
      it 'sets flash message' do
         expect(flash[:notice]).to eq "Your profile was updated successfully."
      end
      it 'returns redirect status' do
         expect(response).to have_http_status(:redirect)
      end
      it 'redirects to mainpage' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

end
