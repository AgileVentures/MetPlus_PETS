require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec::Matchers.define :evt_obj do |*attributes|
  match do |actual|
    if actual.is_a?(Struct)
      attributes.each do |attribute|
        return false unless actual.respond_to?(attribute)
      end
      return true
    end
    false
  end
end

RSpec.describe JobsController, type: :controller do
  let(:agency) { FactoryGirl.create(:agency) }
  let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
  let!(:bosh_utah) { FactoryGirl.create(:address, state: 'Utah', location: bosh) }
  let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
  let(:bosh_job) { FactoryGirl.create(:job, company: bosh, address: bosh_utah) }
  let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
  let(:skill) { FactoryGirl.create(:skill) }
  let!(:valid_params) do
    { title: 'Ruby on Rails', fulltime: true, description: 'passionate',
      company_id: bosh.id, address_id: bosh_mich.id, shift: 'Evening',
      company_job_id: 'WERRR123',
      job_skills_attributes: { '0' => { skill_id: skill.id,
                                        required: 1,
                                        min_years: 2,
                                        max_years: 5,
                                        _destroy: false } } }
  end
  let!(:stub) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    stub_cruncher_job_update
    allow(Pusher).to receive(:trigger)
  end

  describe 'GET #index' do
    let!(:rand_job1) { FactoryGirl.create(:job) }
    let!(:rand_job2) { FactoryGirl.create(:job) }
    context 'company person' do
      before(:each) do
        bosh_job
        warden.set_user bosh_person
        get :index
      end
      it { expect(assigns(:jobs).count).to eq 1 }
      it_behaves_like 'return success and render', 'index'
    end
    context 'others' do
      before(:each) do
        bosh_job
        get :index
      end
      it { expect(assigns(:jobs).count).to eq 3 }
      it_behaves_like 'return success and render', 'index'
    end
  end

  describe 'GET #list_search_jobs' do
    let(:job1) do
      FactoryGirl.create(:job, title: 'Customer Manager',
                               description: 'Provide resposive customer service')
    end
    let(:job2) { FactoryGirl.create(:job) }
    let!(:job_skill1) do
      FactoryGirl.create(:job_skill,
                         job: job1,
                         skill: FactoryGirl.create(:skill, name: 'New Skill 1'))
    end
    let!(:job_skill2) do
      FactoryGirl.create(:job_skill,
                         job: job2,
                         skill: FactoryGirl.create(:skill, name: 'New Skill 2'))
    end
    before(:each) do
      get :list_search_jobs,
          q: { 'title_cont_any': 'customer manager',
               'description_cont_any': 'responsive service' }
    end
    it_behaves_like 'return success and render', 'list_search_jobs'
    it { expect(assigns(:title_words)).to match %w(customer manager) }
    it 'assigns description words for view' do
      expect(assigns(:description_words)).to match %w(responsive service)
    end
    it { expect(assigns(:jobs)[0]).to eq job1 }
  end

  describe 'GET #new' do
    let(:request) { get :new }
    let!(:widget) { FactoryGirl.create(:company, name: 'Widget', agencies: [agency]) }
    let!(:dyson) { FactoryGirl.create(:company, name: 'Dyson', agencies: [agency]) }

    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq([]) }
      it_behaves_like 'return success and render', 'new'
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq([]) }
      it_behaves_like 'return success and render', 'new'
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'company person' do
      before(:each) do
        warden.set_user bosh_person
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'new'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'POST #create' do
    let(:request) { post :create, job: valid_params }

    context 'agency admin' do
      before(:each) { warden.set_user agency_admin }
      describe 'successful POST #create' do
        it 'chanage job count & job skill count by 1' do
          expect { post :create, job: valid_params }
            .to change(Job, :count).by(1).and change(JobSkill, :count).by(1)
        end
        it 'redirects to the jobs index ' do
          request
          expect(response).to redirect_to(action: 'index')
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
      end
      describe 'unsuccessful POST #create' do
        it 'does not change job & job skill count' do
          expect { post :create, job: valid_params.merge(title: ' ') }
            .to change(Job, :count).by(0).and change(Job, :count).by(0)
        end
        it 'return success and render new' do
          post :create, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'new'
        end
      end
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      describe 'successful POST #create' do
        it 'change job & job skill count by 1' do
          expect { post :create, job: valid_params }
            .to change(Job, :count).by(1).and change(JobSkill, :count).by(1)
        end
        it 'redirects to the jobs index ' do
          request
          expect(response).to redirect_to(action: 'index')
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
      end
      describe 'unsuccessful POST #create' do
        it 'does not change job & job skills count' do
          expect { post :create, job: valid_params.merge(title: ' ') }
            .to change(Job, :count).by(0).and change(Job, :count).by(0)
        end
        it 'return success and render new' do
          post :create, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'new'
        end
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) { warden.set_user bosh_person }
      describe 'successful POST #create' do
        it 'chanage job & job skill count by 1' do
          expect { post :create, job: valid_params }
            .to change(Job, :count).by(1).and change(JobSkill, :count).by(1)
        end
        it 'redirects to the jobs index ' do
          request
          expect(response).to redirect_to(action: 'index')
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
      end
      describe 'unsuccessful POST #create' do
        it 'does not change job & job skill count' do
          expect { post :create, job: valid_params.merge(title: ' ') }
            .to change(Job, :count).by(0).and change(Job, :count).by(0)
        end
        it 'return success and render new' do
          post :create, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'new'
        end
      end
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'GET #show' do
    let(:request) { get :show, id: bosh_job }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }

    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:job)).to eq bosh_job }
      it_behaves_like 'return success and render', 'show'
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
      it { expect(assigns(:job)).to eq bosh_job }
      it_behaves_like 'return success and render', 'show'
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) do
        warden.set_user bosh_person
        request
      end
      it { expect(assigns(:job)).to eq bosh_job }
      it_behaves_like 'return success and render', 'show'
    end
    context 'random company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      before(:each) do
        warden.set_user job_seeker
        request
      end
      it { expect(assigns(:job)).to eq bosh_job }
      it_behaves_like 'return success and render', 'show'
    end
    context 'visitor' do
      before(:each) do
        request
      end
      it { expect(assigns(:job)).to eq bosh_job }
      it_behaves_like 'return success and render', 'show'
    end
  end

  describe 'GET #edit' do
    let(:request) { get :edit, id: bosh_job }

    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'edit'
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'edit'
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'own company person' do
      before(:each) do
        warden.set_user bosh_person
        request
      end
      it { expect(assigns(:companies)).to eq Company.all.order(:name) }
      it { expect(assigns(:addresses)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'edit'
    end
    context 'random company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'PATCH #update' do
    let(:request) { patch :update, id: job_wo_skill, job: valid_params }
    let!(:job_wo_skill) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_w_skill) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_skill) { FactoryGirl.create(:job_skill, job: job_w_skill, skill: skill) }

    context 'agency admin' do
      before(:each) { warden.set_user agency_admin }
      describe 'successful update' do
        it 'add job_skill: remain job count, increase 1 job_skill' do
          expect { patch :update, id: job_wo_skill, job: valid_params }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, id: job_w_skill.id,
                           job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(-1)
        end
        it 'redirects to show, show flash' do
          request
          expect(response).to redirect_to(action: 'show')
          expect(flash[:info]).to eq "#{valid_params[:title]} "\
                                     'has been updated successfully.'
        end
      end
      describe 'unsuccessful update' do
        it 'remain job & job skill count' do
          expect { patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ') }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'edit'
        end
      end
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      describe 'successful update' do
        it 'add job_skill: remain job count, increase 1 job_skill' do
          expect { patch :update, id: job_wo_skill, job: valid_params }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, id: job_w_skill.id,
                           job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(-1)
        end
        it 'redirects to show, show flash' do
          request
          expect(response).to redirect_to(action: 'show')
          expect(flash[:info]).to eq "#{valid_params[:title]} "\
                                     'has been updated successfully.'
        end
      end
      describe 'unsuccessful update' do
        it 'remain job & job skill count' do
          expect { patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ') }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'edit'
        end
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) { warden.set_user bosh_person }
      describe 'successful update' do
        it 'add job_skill: remain job count, increase 1 job_skill' do
          expect { patch :update, id: job_wo_skill, job: valid_params }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, id: job_w_skill.id,
                           job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(-1)
        end
        it 'redirects to show, show flash' do
          request
          expect(response).to redirect_to(action: 'show')
          expect(flash[:info]).to eq "#{valid_params[:title]} "\
                                     'has been updated successfully.'
        end
      end
      describe 'unsuccessful update' do
        it 'remain job & job skill count' do
          expect { patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ') }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, id: job_wo_skill, job: valid_params.merge(title: ' ')
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'edit'
        end
      end
    end
    context 'incorrect company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'DESTROY #delete' do
    let!(:job_w_skill) { FactoryGirl.create(:job, company: bosh) }
    let!(:job_skill) { FactoryGirl.create(:job_skill, job: job_w_skill, skill: skill) }
    let(:request) { delete :destroy, id: job_w_skill }

    context 'agency admin' do
      it_behaves_like 'unauthorized', 'agency_admin'
    end
    context 'job developer' do
      it_behaves_like 'unauthorized', 'job_developer'
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) { warden.set_user bosh_person }
      it 'destroys job and associated job_skill' do
        expect { delete :destroy, id: job_w_skill }.to change(Job, :count).by(-1)
      end
      it 'redirects to jobs path & flash[:alert]' do
        request
        expect(response).to redirect_to(jobs_path)
        expect(flash[:alert]).to eq "#{job_w_skill.title} has been deleted successfully."
      end
    end
    context 'random company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'GET #list' do
    let!(:dyson) { FactoryGirl.create(:company, name: 'Dyson', agencies: [agency]) }
    let!(:dyson_person) { FactoryGirl.create(:company_person, company: dyson) }
    let(:request_first_page) { xhr :get, :list, job_type: 'my-company-all' }
    let(:request_last_page) do
      xhr :get, :list, job_type: 'my-company-all', jobs_page: 4
    end
    before(:each) do
      31.times.each do |i|
        title = i < 10 ? "Awesome job 0#{i}" : "Awesome job #{i}"
        FactoryGirl.create(:job, title: title, company: bosh,
                                 company_person: bosh_person)
      end
      4.times.each do |i|
        FactoryGirl.create(:job, title: "Awesome new job #{i}", company: dyson,
                                 company_person: dyson_person)
      end
    end

    describe 'company_person with 3 pages' do
      before(:each) { warden.set_user bosh_person }

      it 'first_page: is a success' do
        request_first_page
        expect(response).to have_http_status(:ok)
      end
      it "first_page: renders 'jobs/_list_jobs' template" do
        request_first_page
        expect(response).to render_template('jobs/_list_jobs')
      end
      it 'first_page: jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        request_first_page
        assigns(:jobs).each {}
        expect(assigns(:jobs).all.size).to be 10
        expect(assigns(:jobs).first.title).to eq 'Awesome job 00'
        expect(assigns(:jobs).last.title).to eq 'Awesome job 09'
      end
      it 'first_page: should not set flash' do
        request_first_page
        should_not set_flash
      end
      it 'last_page: is a success' do
        request_last_page
        expect(response).to have_http_status(:ok)
      end
      it "last_page: renders 'jobs/_list_jobs' template" do
        request_last_page
        expect(response).to render_template('jobs/_list_jobs')
      end
      it 'last_page: check jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        request_last_page
        assigns(:jobs).each {}
        expect(assigns(:jobs).first.title).to eq 'Awesome job 30'
        expect(assigns(:jobs).size).to eq 1
      end
      it 'last_page: should not set flash' do
        request_last_page
        should_not set_flash
      end
    end

    describe 'company_person with 1 page' do
      before :each do
        warden.set_user dyson_person
        request_first_page
      end

      it { expect(response).to have_http_status(:ok) }
      it {  expect(response).to render_template('jobs/_list_jobs') }
      it 'check jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        assigns(:jobs).each {}
        expect(assigns(:jobs).all.size).to be 4
        expect(assigns(:jobs).first.title).to eq 'Awesome new job 0'
        expect(assigns(:jobs).last.title).to eq 'Awesome new job 3'
      end
      it { should_not set_flash }
    end
  end

  describe 'GET #update_addresses' do
    render_views
    before(:each) do
      warden.set_user agency_admin
      xhr :get, :update_addresses, company_id: bosh.id
    end
    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end
    it "renders 'jobs/_address_select' template" do
      expect(response).to render_template('jobs/_address_select')
    end
    it 'returns option tags for addresses' do
      expect(response.body).to have_content(bosh_mich.state.to_s)
      expect(response.body).to have_content(bosh_utah.state.to_s)
    end
  end

  describe 'GET #apply' do
    let!(:testfile_resume) { '/files/Janitor-Resume.doc' }
    let!(:revoked_job) { FactoryGirl.create(:job, status: 'revoked') }
    let!(:job_seeker) do
      js = FactoryGirl.create(:job_seeker)
      js.assign_case_manager(FactoryGirl.create(:case_manager, agency: agency), agency)
      js.assign_job_developer(job_developer, agency)
      js
    end
    let!(:resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let(:request) { get :apply, job_id: bosh_job.id, user_id: job_seeker.id }
    before(:each) { stub_cruncher_file_download testfile_resume }

    describe 'unknown job' do
      before :each do
        warden.set_user job_seeker
        get :apply, job_id: 1000, user_id: job_seeker.id
      end
      it { expect(response).to redirect_to(action: 'index') }
      it 'check set flash' do
        expect(flash[:alert]).to eq 'Unable to find the job the user is'\
        ' trying to apply to.'
      end
    end
    describe 'not active job' do
      before :each do
        warden.set_user job_seeker
        get :apply, job_id: revoked_job.id, user_id: job_seeker.id
      end
      it 'redirect to jobs_path'
      it 'check set flash' do
        expect(flash[:alert]).to eq 'You are not authorized to apply. '\
        'Job has either been filled or revoked.'
      end
    end
    describe 'unknown job seeker' do
      before :each do
        warden.set_user job_developer
        get :apply, job_id: bosh_job.id, user_id: 10_000
      end
      it { expect(response).to redirect_to(action: 'show', id: bosh_job.id) }
      it 'check set flash' do
        expect(flash[:alert]).to eq 'Unable to find the user who wants to apply.'
      end
    end
    context 'agency admin' do
      it_behaves_like 'unauthorized', 'agency_admin'
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      describe 'successful application' do
        before(:each) do
          allow(Event).to receive(:create).and_call_original
          request
        end
        it 'creates a job application' do
          bosh_job.reload
          expect(bosh_job.job_seekers).to include job_seeker
        end
        it 'creates JD_APPLY event' do
          expect(Event).to have_received(:create)
            .with(:JD_APPLY, bosh_job.job_applications.last)
        end
        it 'show flash[:info]' do
          expect(flash[:info]).to be_present.and eq 'Job is successfully applied'\
          " for #{job_seeker.full_name}"
        end
        it { expect(response).to redirect_to(job_path(bosh_job)) }
      end
      describe "invalid application without job seeker's consent" do
        before :each do
          job_seeker.update_attribute(:consent, false)
          request
        end
        after(:each) { job_seeker.update_attribute(:consent, true) }
        it 'show flash[:alert]' do
          expect(flash[:alert]).to be_present.and eq 'You are not authorized to '\
          "apply for #{job_seeker.full_name}."
        end
        it 'redirect to job_path'
      end
      describe 'duplicated application' do
        before :each do
          FactoryGirl.create(:job_application, job: bosh_job, job_seeker: job_seeker)
          request
        end
        it 'shows flash[:alert]' do
          expect(flash[:alert]).to be_present
            .and eq "#{job_seeker.full_name(last_name_first: false)} has already "\
            'applied to this job.'
        end
        it { expect(response).to redirect_to(action: 'show', id: bosh_job.id) }
      end
    end
    context 'random job developer' do
      it_behaves_like 'unauthorized', 'job_developer'
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      before(:each) { warden.set_user job_seeker }
      describe 'successful application' do
        before :each do
          allow(Event).to receive(:create).and_call_original
          request
        end
        it { expect(response).to render_template('jobs/apply') }
        it { should_not set_flash }
        it 'job should have one applicant' do
          bosh_job.reload
          expect(bosh_job.job_seekers).to include job_seeker
        end
        it 'creates JS_APPLY event' do
          expect(Event).to have_received(:create)
            .with(:JS_APPLY, bosh_job.job_applications[0])
        end
      end
      describe 'duplicated applications' do
        before :each do
          FactoryGirl.create(:job_application, job: bosh_job, job_seeker: job_seeker)
          request
        end
        it 'shows flash[:alert]' do
          expect(flash[:alert]).to be_present
            .and eq "#{job_seeker.full_name(last_name_first: false)} has already"\
            ' applied to this job.'
        end
        it { expect(response).to redirect_to(action: 'show', id: bosh_job.id) }
      end
    end
    context 'random job_seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'PATCH #revoke' do
    let!(:revoked_job) { FactoryGirl.create(:job, status: 'revoked', company: bosh) }
    let(:request) { patch :revoke, id: bosh_job.id }

    context 'agency admin' do
      it_behaves_like 'unauthorized', 'agency_admin'
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      context 'active job' do
        it 'changes job status from active to revoked' do
          request
          bosh_job.reload
          expect(bosh_job.status).to eq('revoked')
        end
        it 'creates a job_revoked event' do
          expect(Event).to receive(:create).with(:JOB_REVOKED, evt_obj(:job, :agency))
          request
        end
        it 'flash[:alert] & redirects to jobs_path' do
          request
          expect(response).to redirect_to(jobs_path)
          expect(flash[:alert]).to be_present.and eq "#{bosh_job.title} is revoked "\
          'successfully.'
        end
      end
      context 'revoked job' do
        before :each do
          warden.set_user job_developer
          patch :revoke, id: revoked_job.id
        end
        it 'flash[:alert]' do
          expect(flash[:alert]).to be_present.and eq 'Only active job can be revoked.'
        end
        it { expect(response).to redirect_to(jobs_path) }
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'company person' do
      before(:each) { warden.set_user bosh_person }
      context 'active job' do
        it 'changes job status from active to revoked' do
          request
          bosh_job.reload
          expect(bosh_job.status).to eq('revoked')
        end
        it 'creates a job_revoked event' do
          expect(Event).to receive(:create).with(:JOB_REVOKED, evt_obj(:job, :agency))
          request
        end
        it 'flash[:alert] & redirects to jobs_path' do
          request
          expect(response).to redirect_to(jobs_path)
          expect(flash[:alert]).to be_present.and eq "#{bosh_job.title} is revoked "\
          'successfully.'
        end
      end
      context 'revoked job' do
        before :each do
          warden.set_user job_developer
          patch :revoke, id: revoked_job.id
        end
        it 'flash[:alert]' do
          expect(flash[:alert]).to be_present.and eq 'Only active job can be revoked.'
        end
        it { expect(response).to redirect_to(jobs_path) }
      end
    end
    context 'random company person' do
      it_behaves_like 'unauthorized', 'company_person'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'GET #match_resume' do
    render_views

    let(:job_seeker)  { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2) { FactoryGirl.create(:job_seeker) }
    let!(:resume)     { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let(:job)         { FactoryGirl.create(:job) }
    let(:stars_str)   do
      '<div class="stars"><i class="fa fa-star"' \
      ' aria-hidden="true"></i><i class="fa fa-star"' \
      ' aria-hidden="true"></i><i class="fa fa-star"' \
      ' aria-hidden="true"></i><i class="fa fa-star-half-o"' \
      ' aria-hidden="true"></i><i class="fa fa-star-o"' \
      " aria-hidden=\"true\"></i></div>\n<br>\n3.4 stars\n"
    end

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_upload
    end

    context 'happy path' do
      before(:each) do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job
        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker.id
      end

      it 'returns success status' do
        expect(response).to have_http_status(200)
      end
      it 'renders stars html' do
        expect(JSON.parse(response.body)['stars_html']).to eq stars_str
      end
    end

    context 'sad path' do
      it 'returns 404 status when job seeker does not have resume' do
        warden.set_user job_seeker2
        stub_cruncher_match_resume_and_job

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker2.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message']).to eq 'No résumé on file'
      end

      it 'returns 404 status when job not in Cruncher' do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job_error(:no_job, job.id)

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No job found with id: #{job.id}"
      end

      it 'returns 404 status when resume not in Cruncher' do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job_error(:no_resume, resume.id)

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No resume found with id: #{resume.id}"
      end
    end
  end
end
