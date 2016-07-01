require 'rails_helper'
include JobSeekersViewer

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
    it 'renders home template' do
      expect(response).to render_template('home')
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
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
    let(:aa_role)  { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA]) }
    let!(:jd_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD]) }
    let!(:cm_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM]) }

    let(:agency)     { FactoryGirl.create(:agency) }

    let(:job_seeker) { FactoryGirl.create(:job_seeker) }

    let!(:aa_person)  { FactoryGirl.create(:agency_admin, agency: agency) }

    let!(:jd_person) {FactoryGirl.create(:job_developer,
              first_name: 'John', last_name: 'Developer', agency: agency)}

    let!(:cm_person) {FactoryGirl.create(:case_manager,
              first_name: 'Kevin', last_name: 'Caseman', agency: agency)}

    let!(:adam)    { FactoryGirl.create(:job_seeker, first_name: 'Adam', last_name: 'Smith') }

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
      render_views

      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = []
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = []
        patch :update, id: aa_person, agency_person: person_hash
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it 'renders partial for errors' do
        expect(response).to render_template(partial: 'shared/_error_messages')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'assign as job developer fails when not in that role' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = []
        person_hash[:as_jd_job_seeker_ids] = [job_seeker.id]
        person_hash[:as_cm_job_seeker_ids] = []
        patch :update, id: aa_person, agency_person: person_hash
      end

      it 'sets model error message' do
        expect(assigns(:agency_person).errors[:person]).
          to include('cannot be assigned as Job Developer unless person has that role.')
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'assign as case manager fails when not in that role' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = []
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = [job_seeker.id]
        patch :update, id: aa_person, agency_person: person_hash
      end

      it 'sets model error message' do
        expect(assigns(:agency_person).errors[:person]).
          to include('cannot be assigned as Case Manager unless person has that role.')
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'assign job seekers to job developer' do

      let(:person_hash) do
        person_hash = jd_person.attributes
        person_hash[:agency_role_ids] = [jd_role.id]
        person_hash[:as_jd_job_seeker_ids] = [job_seeker.id, adam.id]
        person_hash[:as_cm_job_seeker_ids] = []
        person_hash
      end

      before(:each) do
        allow(Pusher).to receive(:trigger)
      end

      it 'assigns job seekers to the job developer' do
        patch :update, id: jd_person, agency_person: person_hash
        expect(assigns(:agency_person).as_jd_job_seeker_ids).
            to eq [job_seeker.id, adam.id]
      end
      it 'sends notification email to JD for each job seeker' do
        expect { patch :update, id: jd_person, agency_person: person_hash }.
                      to change(all_emails, :count).by(+2)
      end
    end

    context 'assign job seekers to case manager' do

      let(:person_hash) do
        person_hash = cm_person.attributes
        person_hash[:agency_role_ids] = [cm_role.id]
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = [job_seeker.id, adam.id]
        person_hash
      end

      before(:each) do
        allow(Pusher).to receive(:trigger)
      end

      it 'assigns job seekers to the case manager' do
        patch :update, id: cm_person, agency_person: person_hash
        expect(assigns(:agency_person).as_cm_job_seeker_ids).
            to eq [job_seeker.id, adam.id]
      end
      it 'sends notification email to CM for each job seeker' do
        expect { patch :update, id: cm_person, agency_person: person_hash }.
                      to change(all_emails, :count).by(+2)
      end
    end

  end

  describe 'PATCH #assign_job_seeker' do

    let(:job_developer) { FactoryGirl.create(:job_developer) }
    let(:case_manager)  { FactoryGirl.create(:case_manager) }
    let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

    context 'assign job developer to job seeker' do

      before do |example|
        unless example.metadata[:skip_before]
          xhr :patch, :assign_job_seeker, id: job_developer.id,
                      job_seeker_id: job_seeker.id, agency_role: 'JD'
        end
      end

      it 'assigns agency_person instance var' do
        expect(assigns(:agency_person)).to eq job_developer
      end
      it 'assigns job_seeker instance var' do
        expect(assigns(:job_seeker)).to eq job_seeker
      end
      it 'returns error if unknown agency_role specified', :skip_before do
        xhr :patch, :assign_job_seeker, id: job_developer.id,
                    job_seeker_id: job_seeker.id, agency_role: 'XYZ'

        expect(response).to have_http_status(:bad_request)
      end
      it 'returns error if attempt to assign JD role to CM', :skip_before do
        xhr :patch, :assign_job_seeker, id: case_manager.id,
                    job_seeker_id: job_seeker.id, agency_role: 'JD'

        expect(response).to have_http_status(:forbidden)
      end
      it 'increases agency_role count', :skip_before do
        expect {xhr :patch, :assign_job_seeker, id: job_developer.id,
                    job_seeker_id: job_seeker.id, agency_role: 'JD'}.
            to change(AgencyRelation, :count).by(+1)
      end
      it 'assigns job developer to job seeker' do
        expect(assigns(:job_seeker).job_developer).to eq job_developer
      end
      it 'renders partial' do
        expect(response).to render_template(partial: '_assigned_agency_person')
      end
    end

    context 'assign case manager to job seeker' do

      before do |example|
        unless example.metadata[:skip_before]
          xhr :patch, :assign_job_seeker, id: case_manager.id,
                      job_seeker_id: job_seeker.id, agency_role: 'CM'
        end
      end

      it 'assigns agency_person instance var' do
        expect(assigns(:agency_person)).to eq case_manager
      end
      it 'assigns job_seeker instance var' do
        expect(assigns(:job_seeker)).to eq job_seeker
      end
      it 'returns error if unknown agency_role specified', :skip_before do
        xhr :patch, :assign_job_seeker, id: case_manager.id,
                    job_seeker_id: job_seeker.id, agency_role: 'XYZ'

        expect(response).to have_http_status(:bad_request)
      end
      it 'returns error if attempt to assign CM role to JD', :skip_before do
        xhr :patch, :assign_job_seeker, id: job_developer.id,
                    job_seeker_id: job_seeker.id, agency_role: 'CM'

        expect(response).to have_http_status(:forbidden)
      end
      it 'increases agency_role count', :skip_before do
        expect {xhr :patch, :assign_job_seeker, id: case_manager.id,
                    job_seeker_id: job_seeker.id, agency_role: 'CM'}.
            to change(AgencyRelation, :count).by(+1)
      end
      it 'assigns case manager to job seeker' do
        expect(assigns(:job_seeker).case_manager).to eq case_manager
      end
      it 'renders partial' do
        expect(response).to render_template(partial: '_assigned_agency_person')
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
  
  describe 'GET #list_js_cm' do
    
    let(:case_manager) { FactoryGirl.create(:case_manager) }
    
    let(:job_seeker)  { FactoryGirl.create(:job_seeker, first_name: 'Bob',      last_name: 'Smith') }
    
      
    before(:each) do
      
      sign_in case_manager
      job_seeker.assign_case_manager(case_manager,case_manager.agency)
      xhr :get, :list_js_cm, id: case_manager.id,
                people_type: 'jobseeker-cm'
    end
    it 'assigns @people to collection of casemanager to jobseeker people' do
      expect(assigns(:people)).to include job_seeker
    end
    it 'renders agency_people/assigned_job_seekers template' do
      expect(response).to render_template('agency_people/_assigned_job_seekers')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
