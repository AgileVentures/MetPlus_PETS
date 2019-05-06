require 'rails_helper'
include JobSeekersViewer

RSpec.describe AgencyPeopleController, type: :controller do
  let!(:agency)    { FactoryBot.create(:agency) }
  let!(:aa_person) { FactoryBot.create(:agency_admin, agency: agency) }
  let!(:cm_person) { FactoryBot.create(:case_manager, agency: agency) }
  let!(:jd_person) { FactoryBot.create(:job_developer, agency: agency) }
  let(:adam)       { FactoryBot.create(:job_seeker, first_name: 'Adam') }
  let(:bob)        { FactoryBot.create(:job_seeker, first_name: 'Bob') }
  let(:charles)    { FactoryBot.create(:job_seeker, first_name: 'Charles') }
  let(:dave)       { FactoryBot.create(:job_seeker, first_name: 'Dave') }

  let(:aa_role) { FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:AA]) }
  let(:jd_role) { FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD]) }
  let(:cm_role) { FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:CM]) }

  describe 'GET #home' do
    before(:each) do
      adam.assign_job_developer(jd_person, agency)
      bob.assign_case_manager(cm_person, agency)
      sign_in jd_person
      get :home, params: { id: jd_person }
    end

    it 'assigns @agency_person for view' do
      expect(assigns(:agency_person)).to eq jd_person
    end
    it 'renders home template' do
      expect(response).to render_template('home')
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    context 'job developer scenarios' do
      before(:each) do
        adam.assign_job_developer(jd_person, agency)
        bob.assign_case_manager(cm_person, agency)
        sign_in jd_person
        get :home, params: { id: jd_person }
      end

      it "returns job developer's jobseekers" do
        expect(assigns(:your_jobseekers_jd)).to include(adam)
      end

      it 'returns a list of jobseekers without a job developer' do
        expect(assigns(:js_without_jd)).to match_array([bob, charles, dave])
      end
    end

    context 'case manager scenarios' do
      before(:each) do
        adam.assign_job_developer(jd_person, agency)
        bob.assign_case_manager(cm_person, agency)
        sign_in cm_person
        get :home, params: { id: cm_person }
      end

      it "returns case_manager's jobseekers" do
        expect(assigns(:your_jobseekers_cm)).to include(bob)
      end

      it 'returns a list of jobseekers without a case manager' do
        expect(assigns(:js_without_cm)).to match_array([adam, charles, dave])
      end
    end
  end

  describe 'GET #show' do
    before(:each) do
      sign_in jd_person
      get :show, params: { id: jd_person.id }
    end

    it 'assigns @agency_person for view' do
      expect(assigns(:agency_person)).to eq jd_person
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    before(:each) do
      sign_in aa_person
      get :edit, params: { id: jd_person }
    end

    it 'assigns @agency_person for form' do
      expect(assigns(:agency_person)).to eq jd_person
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:assign_agency_person_mock) do
      instance_double('AgencyPeople::AssignNewJobSeekers')
    end
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    before(:each) do
      allow(AgencyPeople::AssignNewJobSeekers)
        .to receive(:new).and_return(assign_agency_person_mock)
      allow(assign_agency_person_mock)
        .to receive(:call)
      allow(Event).to receive(:create)
    end

    context 'valid attributes' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = [aa_role.id.to_s]
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = []
        sign_in aa_person
        patch :update, params: { id: aa_person,
                                 agency_person: person_hash }
      end
      it 'assigns @agency_person for updating' do
        expect(assigns(:agency_person)).to eq aa_person
      end

      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Agency person was successfully updated.'
      end

      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to branch #show view' do
        expect(response).to redirect_to(agency_person_path(aa_person))
      end
    end

    context 'assign as job developer fails when not in that role' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:as_jd_job_seeker_ids] = [job_seeker.id]
        person_hash[:as_cm_job_seeker_ids] = []
        sign_in aa_person

        allow(assign_agency_person_mock)
          .to receive(:call)
          .and_raise(JobSeekers::AssignAgencyPerson::NotAJobDeveloper)
        patch :update, params: { id: aa_person, agency_person: person_hash }
      end

      it 'sets model error message' do
        expect(assigns(:agency_person).errors[:person])
          .to include('cannot be assigned as Job Developer unless person has that role.')
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'assign as case manager fails when not in that role' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = [job_seeker.id]
        sign_in aa_person

        allow(assign_agency_person_mock)
          .to receive(:call)
          .and_raise(JobSeekers::AssignAgencyPerson::NotACaseManager)
        patch :update, params: { id: aa_person, agency_person: person_hash }
      end

      it 'sets model error message' do
        expect(assigns(:agency_person).errors[:person])
          .to include('cannot be assigned as Case Manager unless person has that role.')
      end

      it 'renders edit template' do
        expect(response).to render_template('edit')
      end

      it 'returns http success' do
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
        sign_in aa_person
        patch :update, params: { id: jd_person, agency_person: person_hash }
      end

      it 'calls interactor to assign the JD' do
        expect(assign_agency_person_mock)
          .to have_received(:call).twice
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
        sign_in aa_person
        patch :update, params: { id: cm_person, agency_person: person_hash }
      end

      it 'calls interactor to assign the Case Manager' do
        expect(assign_agency_person_mock)
          .to have_received(:call).twice
      end
    end
  end

  describe 'PATCH #assign_job_seeker' do
    let!(:assign_agency_person_mock) { instance_double('JobSeekers::AssignAgencyPerson') }

    before(:each) do
      allow(JobSeekers::AssignAgencyPerson)
        .to receive(:new).and_return(assign_agency_person_mock)
      allow(assign_agency_person_mock)
        .to receive(:call)

      allow(subject).to receive(:authorize)
    end

    context 'assign job developer to job seeker' do
      before do |example|
        allow(Pusher).to receive(:trigger)
        sign_in aa_person
        unless example.metadata[:skip_before]
          patch :assign_job_seeker, params: { id: jd_person.id,
                                              job_seeker_id: adam.id,
                                              agency_role: 'JD' },
                                    xhr: true
        end
      end

      context 'when is able to assign' do
        it 'authorizes the job developer' do
          expect(subject).to have_received(:authorize).with(jd_person)
        end

        it 'calls interactor to assign the JD' do
          expect(assign_agency_person_mock)
            .to have_received(:call)
            .with(adam, :JD, jd_person)
        end

        it 'renders partial' do
          expect(response).to render_template(partial: '_assigned_agency_person')
        end
      end

      context 'when the agency person is not a JD' do
        it 'returns error', :skip_before do
          allow(assign_agency_person_mock)
            .to receive(:call)
            .and_raise(JobSeekers::AssignAgencyPerson::NotAJobDeveloper)
          patch :assign_job_seeker, params: { id: cm_person.id,
                                              job_seeker_id: adam.id,
                                              agency_role: 'JD' },
                                    xhr: true

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'assign case manager to job seeker' do
      before do |example|
        allow(Pusher).to receive(:trigger)
        sign_in aa_person
        unless example.metadata[:skip_before]
          patch :assign_job_seeker, params: { id: cm_person.id,
                                              job_seeker_id: adam.id,
                                              agency_role: 'CM' },
                                    xhr: true
        end
      end

      context 'when is able to assign' do
        it 'authorizes the case manager' do
          expect(subject).to have_received(:authorize).with(cm_person)
        end

        it 'calls interactor to assign the JD' do
          expect(assign_agency_person_mock)
            .to have_received(:call)
            .with(adam, :CM, cm_person)
        end

        it 'renders partial' do
          expect(response).to render_template(partial: '_assigned_agency_person')
        end
      end
      context 'when the agency person is not a CM' do
        it 'returns error', :skip_before do
          allow(assign_agency_person_mock)
            .to receive(:call)
            .and_raise(JobSeekers::AssignAgencyPerson::NotACaseManager)
          patch :assign_job_seeker, params: { id: jd_person.id,
                                              job_seeker_id: adam.id,
                                              agency_role: 'CM' },
                                    xhr: true
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'assign unknown agency role' do
      it 'returns error' do
        allow(Pusher).to receive(:trigger)
        allow(assign_agency_person_mock)
          .to receive(:call)
          .and_raise(JobSeekers::AssignAgencyPerson::InvalidRole)

        sign_in aa_person
        patch :assign_job_seeker, params: { id: cm_person.id,
                                            job_seeker_id: adam.id,
                                            agency_role: 'AA' },
                                  xhr: true

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET #destroy' do
    before(:each) do
      sign_in aa_person
      get :destroy, params: { id: cm_person.id }
    end

    it 'sets flash message' do
      expect(flash[:notice])
        .to eq "Person '#{cm_person.full_name(last_name_first: false)}' deleted."
    end

    it 'returns http success' do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #edit_profile' do
    before(:each) do
      sign_in jd_person
      get :edit_profile, params: { id: jd_person }
    end

    it 'assigns @agency_person for form' do
      expect(assigns(:agency_person)).to eq jd_person
    end

    it 'renders edit_profile template' do
      expect(response).to render_template('edit_profile')
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update_profile' do
    context 'valid attributes' do
      before(:each) do
        person_hash = aa_person.attributes.merge(aa_person.user.attributes)
        sign_in aa_person
        patch :update_profile, params: { id: aa_person,
                                         agency_person: person_hash }
      end

      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Your profile was updated successfully.'
      end

      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to agency person home page' do
        expect(response).to redirect_to(home_agency_person_path(aa_person))
      end
    end

    context 'valid attributes without password change' do
      before(:each) do
        @password = aa_person.encrypted_password
        sign_in aa_person
        patch :update_profile,
              params: { agency_person:
                FactoryBot.attributes_for(:agency_person,
                                          password: '',
                                          password_confirmation: '')
                          .merge(FactoryBot.attributes_for(:user,
                                                           first_name: 'John',
                                                           last_name: 'Smith',
                                                           phone: '780-890-8976')),
                        id: aa_person }
        aa_person.reload
      end

      it 'sets a firstname' do
        expect(aa_person.first_name).to eq 'John'
      end

      it 'sets a lastname' do
        expect(aa_person.last_name).to eq 'Smith'
      end

      it 'dont change password' do
        expect(aa_person.encrypted_password).to eq @password
      end

      it 'sets flash message' do
        expect(flash[:warning])
          .to eq 'Please check your inbox to confirm your email address'
      end

      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to agency person home page' do
        expect(response).to redirect_to(home_agency_person_path(aa_person))
      end
    end
  end

  describe 'GET #list_js_cm' do
    before(:each) do
      sign_in cm_person
      adam.assign_case_manager(cm_person, cm_person.agency)
      get :list_js_cm, params: { id: cm_person.id,
                                 people_type: 'jobseeker-cm' },
                       xhr: true
    end

    it 'assigns @people to collection of job seekers for case manager' do
      expect(assigns(:people)).to include adam
    end

    it 'renders agency_people/assigned_job_seekers template' do
      expect(response).to render_template('agency_people/_assigned_job_seekers')
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #list_js_jd' do
    before(:each) do
      sign_in jd_person
      adam.assign_job_developer(jd_person, jd_person.agency)
      get :list_js_jd, params: { id: jd_person.id,
                                 people_type: 'jobseeker-jd' },
                       xhr: true
    end

    it 'assigns @people to collection of job seekers for casemanager' do
      expect(assigns(:people)).to include adam
    end

    it 'renders agency_people/assigned_job_seekers template' do
      expect(response).to render_template('agency_people/_assigned_job_seekers')
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #my_js_as_jd' do
    context 'job developer cum case manager with job seekers' do
      before :each do
        @jd_cm = FactoryBot.create(:jd_cm, agency: agency)
        @job_developer = FactoryBot.create(:job_developer, agency: agency)

        @user1 = FactoryBot.create(:user, first_name: 'John', last_name: 'Joe')
        @js1 = FactoryBot.create(:job_seeker, user: @user1)
        @js1.assign_job_developer(@jd_cm, agency)

        @user2 = FactoryBot.create(:user, first_name: 'Jack', last_name: 'Doe')
        @js2 = FactoryBot.create(:job_seeker, user: @user2)
        @js2.assign_job_developer(@jd_cm, agency)

        @user3 = FactoryBot.create(:user, first_name: 'Adam', last_name: 'Doe')
        @js3 = FactoryBot.create(:job_seeker, user: @user3)
        @js3.assign_job_developer(@jd_cm, agency)

        @js4 = FactoryBot.create(:job_seeker)
        @js4.assign_job_developer(@job_developer, agency)
        @js4.assign_case_manager(@jd_cm, agency)

        sign_in @jd_cm
      end

      it 'returns http success' do
        get :my_js_as_jd, params: { id: @jd_cm.id }, format: :json, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns his job seekers in alphabetical order' do
        [@js1, @js2, @js3].each do |js|
          FactoryBot.create(:resume, job_seeker: js)
        end

        get :my_js_as_jd, params: { id: @jd_cm.id }, format: :json, xhr: true
        expect(JSON.parse(response.body))
          .to eq('results' =>
            [
              { 'id' => @js3.id, 'text' => @js3.full_name },
              { 'id' => @js2.id, 'text' => @js2.full_name },
              { 'id' => @js1.id, 'text' => @js1.full_name }
            ])
      end

      it 'returns his job seekers with consent' do
        [@js1, @js2, @js3].each do |js|
          FactoryBot.create(:resume, job_seeker: js)
        end

        @js1.update_attribute(:consent, false)
        get :my_js_as_jd, params: { id: @jd_cm.id }, format: :json, xhr: true
        expect(JSON.parse(response.body))
          .to eq('results' =>
            [
              { 'id' => @js3.id, 'text' => @js3.full_name },
              { 'id' => @js2.id, 'text' => @js2.full_name }
            ])
      end

      it 'disables application for his job seekers without resume' do
        FactoryBot.create(:resume, job_seeker: @js1)
        get :my_js_as_jd, params: { id: @jd_cm.id }, format: :json, xhr: true
        expect(JSON.parse(response.body))
          .to eq('results' =>
            [
              { 'id' => @js3.id, 'text' => @js3.full_name, 'disabled' => 'disabled' },
              { 'id' => @js2.id, 'text' => @js2.full_name, 'disabled' => 'disabled' },
              { 'id' => @js1.id, 'text' => @js1.full_name }
            ])
      end
    end

    context 'job developer without job seeker' do
      before :each do
        @job_developer1 = FactoryBot.create(:job_developer, agency: agency)
        @js1 = FactoryBot.create(:job_seeker)
        @js2 = FactoryBot.create(:job_seeker)
        sign_in @job_developer1
        get :my_js_as_jd, params: { id: @job_developer1.id }, format: :json, xhr: true
      end

      it 'returns http success' do
        expect(response).to have_http_status(403)
      end

      it 'check content' do
        expect(response.body)
          .to eq({ message: 'You do not have job seekers!' }.to_json)
      end
    end
  end

  describe 'action authorization' do
    context '#show' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(jd_person)
        get :show, params: { id: cm_person.id }
      end
      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(adam)
        get :show, params: { id: cm_person.id }
        expect(flash[:alert])
          .to eq 'You are not authorized to show an agency person.'
      end
    end

    context '#edit' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(aa_person)
        get :edit, params: { id: cm_person.id }
      end

      it 'does not authorize non-agency admin' do
        allow(controller).to receive(:current_user).and_return(jd_person)
        get :edit, params: { id: cm_person.id }
        expect(flash[:alert])
          .to eq 'You are not authorized to edit an agency person.'
      end
    end

    context '#update' do
      let(:person_hash) do
        person_hash = cm_person.attributes.merge(aa_person.user.attributes)
        person_hash[:agency_role_ids] = [cm_role.id.to_s]
        person_hash[:as_jd_job_seeker_ids] = []
        person_hash[:as_cm_job_seeker_ids] = []
        person_hash
      end

      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(aa_person)
        get :update, params: { id: cm_person.id, agency_person: person_hash }
      end

      it 'does not authorize non-agency admin' do
        allow(controller).to receive(:current_user).and_return(jd_person)
        get :update, params: { id: cm_person.id, agency_person: person_hash }
        expect(flash[:alert])
          .to eq 'You are not authorized to edit an agency person.'
      end
    end

    context '#home' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        get :home, params: { id: cm_person.id }
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(bob)
        get :home, params: { id: cm_person.id }
        expect(flash[:alert])
          .to eq 'You are not authorized to go to agency person home page.'
      end
    end

    context '#assign_job_seeker' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        patch :assign_job_seeker, params: { id: cm_person.id, job_seeker_id: bob.id,
                                            agency_role: 'JD' }
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(charles)
        patch :assign_job_seeker, params: { id: cm_person.id, job_seeker_id: bob.id,
                                            agency_role: 'JD' }
        expect(flash[:alert])
          .to eq 'You are not authorized to assign a job seeker.'
      end
    end

    context '#edit_profile' do
      it 'authorizes agency person for himself' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        get :edit_profile, params: { id: cm_person.id }
      end

      it 'does not authorize agency person to edit other agency person' do
        allow(controller).to receive(:current_user).and_return(jd_person)
        get :edit_profile, params: { id: cm_person.id }
        expect(flash[:alert])
          .to eq "You are not authorized to edit agency person's profile."
      end
    end

    context '#update_profile' do
      it 'authorizes agency person for himself' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        patch :update_profile, params: { id: cm_person.id,
                                         agency_person: attributes_for(:agency_person) }
      end

      it 'does not authorize agency person to update other agency person' do
        allow(controller).to receive(:current_user).and_return(jd_person)
        patch :update_profile, params: { id: cm_person.id,
                                         agency_person: attributes_for(:agency_person) }
        expect(flash[:alert])
          .to eq "You are not authorized to edit agency person's profile."
      end
    end

    context '#destroy' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(aa_person)
        patch :destroy, params: { id: cm_person.id }
      end

      it 'does not authorize non-admin agency person' do
        allow(controller).to receive(:current_user).and_return(jd_person)
        patch :destroy, params: { id: cm_person.id }
        expect(flash[:alert])
          .to eq 'You are not authorized to destroy agency person.'
      end
    end

    context '#list_js_cm' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        get :list_js_cm, params: { id: cm_person.id, people_type: 'jobseeker-cm' },
                         xhr: true
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(bob)
        get :list_js_cm, params: { id: cm_person.id, people_type: 'jobseeker-cm' },
                         xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
            'You are not authorized to access job seekers assigned to CM.')
      end
    end

    context '#list_js_jd' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(jd_person)
        get :list_js_jd, params: { id: jd_person.id, people_type: 'jobseeker-jd' },
                         xhr: true
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(bob)
        get :list_js_jd, params: { id: jd_person.id, people_type: 'jobseeker-cm' },
                         xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
            'You are not authorized to access job seekers assigned to JD.')
      end
    end

    context '#list_js_without_cm' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        get :list_js_without_cm, params: { id: cm_person.id,
                                           people_type: 'jobseeker-without-cm' },
                                 xhr: true
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(bob)
        get :list_js_without_cm, params: { id: cm_person.id,
                                           people_type: 'jobseeker-without-cm' },
                                 xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
            'You are not authorized to access job seekers without a CM.')
      end
    end

    context '#list_js_without_jd' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(cm_person)
        get :list_js_without_jd, params: { id: cm_person.id,
                                           people_type: 'jobseeker-without-jd' },
                                 xhr: true
      end

      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(bob)
        get :list_js_without_jd, params: { id: cm_person.id,
                                           people_type: 'jobseeker-without-jd' },
                                 xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
            'You are not authorized to access job seekers without a JD.')
      end
    end
  end
end
