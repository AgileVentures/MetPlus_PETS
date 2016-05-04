require 'rails_helper'

RSpec.describe AgencyPeopleController, type: :controller do
  describe "GET #home" do
    let(:agency) { FactoryGirl.create(:agency) }

    let!(:cm_person) {FactoryGirl.create(:case_manager, first_name: 'John', last_name: 'Manager', agency: agency)}
    let!(:jd_person) {FactoryGirl.create(:job_developer, first_name: 'John', last_name: 'Developer', agency: agency)}
    let!(:aa_person) {FactoryGirl.create(:agency_admin, first_name: 'John', last_name: 'Admin', agency: agency)}

    let!(:adam)    { FactoryGirl.create(:job_seeker, first_name: 'Adam', last_name: 'Smith') }
    let!(:bob)     { FactoryGirl.create(:job_seeker, first_name: 'Bob', last_name: 'Smith') }
    let!(:charles) { FactoryGirl.create(:job_seeker, first_name: 'Charles', last_name: 'Smith') }
    let!(:dave)    { FactoryGirl.create(:job_seeker, first_name: 'Dave', last_name: 'Smith') }


    before(:each) do
      adam.assign_job_developer(jd_person, agency)
      bob.assign_case_manager(cm_person, agency)
      get :home, id: jd_person
    end

    it 'assigns @agency_person for view' do
      expect(assigns(:agency_person)).to eq jd_person
    end
    #byebug
    it 'renders home template' do
      expect(response).to render_template('home')
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    context 'tasks' do
      before (:each) do
        @my_open_task = Task.new_js_unassigned_jd_task(charles, agency)
        @my_open_task.assign jd_person
      end
      it 'displays my tasks' do
        expect(@task_type_t1).to include(@my_open_task)
      end
      it 'does not display tasks not mine' do

      end
    end

    context 'job developer scenarios' do
      before(:each) do
        adam.assign_job_developer(jd_person, agency)
        bob.assign_case_manager(cm_person, agency)
        get :home, id: jd_person
      end

      it "returns job developer's jobseekers" do
        expect(assigns(:your_jobseekers_jd)).to include(adam)
      end

     it "returns a list of jobseekers without a job developer" do
       expect(assigns(:js_without_jd)).to match_array([bob, charles, dave])
     end
   end

   context 'case manager scenarios' do
     before(:each) do
       adam.assign_job_developer(jd_person, agency)
       bob.assign_case_manager(cm_person, agency)
       get :home, id: cm_person
     end

     it "returns case_manager's jobseekers" do
       expect(assigns(:your_jobseekers_cm)).to include(bob)
     end

     it "returns a list of jobseekers without a case manager" do
       expect(assigns(:js_without_cm)).to match_array([adam, charles, dave])
     end

   end
  end


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
    let(:agency_person)  { FactoryGirl.create(:agency_person) }

    before(:each) { get :edit_profile, id: agency_person }

    it 'assigns @agency_person for form' do
      expect(assigns(:agency_person)).to eq agency_person
    end
    it 'renders edit_profile template' do
      expect(response).to render_template('edit_profile')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update_profile" do

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
        patch :update_profile, id: aa_person,
            agency_person: person_hash
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
         @password = aa_person.encrypted_password
         patch :update_profile,
           agency_person:FactoryGirl.attributes_for(:agency_person,
           password: '', password_confirmation: '').
           merge(FactoryGirl.attributes_for(:user, first_name:'John',
           last_name:'Smith',phone:'780-890-8976')),
           id: aa_person
         aa_person.reload
       end
      it 'sets a firstname' do
         expect(aa_person.first_name).to eq ("John")
      end
      it 'sets a lastname' do
         expect(aa_person.last_name).to eq ("Smith")
      end
       it 'dont change password' do
         expect(aa_person.encrypted_password).to eq (@password)
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
