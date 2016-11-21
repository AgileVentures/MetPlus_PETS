require 'rails_helper'
include ServiceStubHelpers::Cruncher

module Helpers
  def assign_role(role)
    let(:agency) { FactoryGirl.create(:agency) }
    let(:company) { FactoryGirl.create(:company, agencies: [agency]) }
    case role
    when 'job_seeker'
      let(:person) { FactoryGirl.create(:job_seeker) }
    when 'company_person', 'company_admin', 'company_contact'
      let(:person) { FactoryGirl.send(:create, role.to_sym, company: company) }
    when 'agency_person', 'job_developer', 'case_manager', 'agency_admin'
      let(:person) { FactoryGirl.send(:create, role.to_sym, agency: agency) }
    else
      let(:person) { nil }
    end
  end
end

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

RSpec.configure { |c| c.extend Helpers }
RSpec.shared_examples 'unauthorized' do |role|
  assign_role(role)
  before :each do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    warden.set_user person
    request
  end
  it { expect(response).to have_http_status(:redirect) }
  it 'sets flash[:alert] message' do
    expect(flash[:alert]).to match('You are not authorized to')
      .or eq('You need to login to perform this action.')
  end
end

RSpec.shared_examples 'unauthorized (xhr)' do |role|
  assign_role(role)
  before :each do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    warden.set_user person
    request
  end
  it 'returns http unauthorized / forbidden' do
    expect(response).to have_http_status(:unauthorized)
      .or have_http_status(:forbidden)
  end
  it 'returns unauthenticated / unauthorized message' do
    expect(JSON.parse(response.body, symbolize_names: true)[:message])
      .to eq('You need to login to perform this action.')
      .or match('You are not authorized to')
  end
end

RSpec.shared_examples 'return success and render' do |action|
  it { expect(response).to have_http_status(:success) }
  it { expect(response).to render_template "#{action}" }
end

RSpec.describe JobsController, type: :controller do
  let(:agency) { FactoryGirl.create(:agency) }

  describe 'GET #new' do
    let(:request) { get :new }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let!(:widget) { FactoryGirl.create(:company, name: 'Widget', agencies: [agency]) }
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:dyson) { FactoryGirl.create(:company, name: 'Dyson', agencies: [agency]) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end
    context 'agency admin' do
      before(:each) do 
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:company)).to eq Company.all.order(:name) }
      it { expect(assigns(:address)).to eq([]) }
      it_behaves_like 'return success and render', 'new'
    end
    context 'job developer' do
      before(:each) do 
        warden.set_user job_developer
        request
      end
      it { expect(assigns(:company)).to eq Company.all.order(:name) }
      it { expect(assigns(:address)).to eq([]) }
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
      it { expect(assigns(:company)).to eq([bosh]) }
      it { expect(assigns(:address)).to eq([]) }
      it_behaves_like 'return success and render', 'new'
    end
    context 'job seeker' do
      it_behaves_like 'unauthorized', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'GET #edit' do
    let(:request) { get :edit, id: bosh_job }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_utah) { FactoryGirl.create(:address, state: 'Utah', location: bosh) }
    let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
    let!(:bosh_job) { FactoryGirl.create(:job, company: bosh, address: bosh_utah) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end
    context 'agency admin' do
      before(:each) do 
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:company)).to eq Company.all.order(:name) }
      it { expect(assigns(:address)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'edit'
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
      it { expect(assigns(:company)).to eq Company.all.order(:name) }
      it { expect(assigns(:address)).to eq bosh.addresses.order(:state) }
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
      it { expect(assigns(:company)).to eq([bosh]) }
      it { expect(assigns(:address)).to eq bosh.addresses.order(:state) }
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

  describe 'POST #create' do
    let(:skill) { FactoryGirl.create(:skill) }
    let!(:valid_params) do
      { title: 'Ruby on Rails',
        fulltime: true,
        description: 'passionate',
        company_id: bosh.id,
        address_id: bosh_mich.id,
        shift: 'Evening',
        company_job_id: 'WERRR123',
        job_skills_attributes: 
        { '0' => { skill_id: skill.id,
                  required: 1, min_years: 2,
                  max_years: 5, _destroy: false }
        } 
      }
    end
    let(:request) { post :create, job: valid_params }
    let!(:job1) { FactoryGirl.create(:job) }
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
    let!(:bosh_job) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
      allow(Pusher).to receive(:trigger)
    end
    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
      end
      describe 'successful POST #create' do
        it { expect{ post :create, job: valid_params }.to change(Job, :count).by(1) }
        it 'redirects to the jobs index ' do
          request
          expect(response).to redirect_to(action: 'index')
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
      end
      describe 'unsuccessful POST #create' do
        it 'does not change #count' do 
          expect{ post :create, job: valid_params.merge(title: ' ') }.
          to change(Job, :count).by(0)
        end
        
          post :create, job: valid_params.merge(title: ' ')
          it_behaves_like 'return success and render', 'new'
       
      end
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
      end
      describe 'successful POST #create' do
        it {expect(Job.count).to eq(2)}
        it 'redirects to the jobs index and increase 1 job' do
          request
          expect(response).to redirect_to(action: 'index')
          should set_flash
          expect(Job.count).to eq(3)
          expect(response.status).to eq(302)
        end
      end
      describe 'unsuccessful POST #create' do
        it 'render new, remain 2 jobs and 0 job skills' do
          post :create, job: valid_params.merge(title: ' ')
          expect(response).to render_template('new')
          expect(Job.count).to eq(2)
          expect(response.status).to eq(200)
        end
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) do
        warden.set_user bosh_person
      end
      describe 'successful POST #create' do
        it 'has 2 jobs and 0 job_skills at the start' do
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(0)
        end
        it 'redirects to index, increase job and job_skills by 1' do
          request
          expect(response).to redirect_to(action: 'index')
          should set_flash
          expect(Job.count).to eq(3)
          expect(JobSkill.count).to eq(1)
          expect(response.status).to eq(302)
        end
      end
      describe 'unsuccessful POST #create with empty attribute' do
        it 'render new, remain 2 jobs and 0 job skills' do
          post :create, job: valid_params.merge(title: ' ')
          expect(response).to render_template('new')
          expect(Job.count).to eq(2)
          expect(response.status).to eq(200)
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

  describe 'PATCH #update' do
    let(:skill) { FactoryGirl.create(:skill) }
    let!(:valid_params) do
      { title: 'Ruby on Rails',
        fulltime: true,
        description: 'passionate',
        shift: 'Evening',
        company_job_id: 'WERRR123',
        job_skills_attributes: {
          '0' => { skill_id: skill.id,
                   required: 1, min_years: 2,
                   max_years: 5, _destroy: false }
        } }
    end
    let(:request) { patch :update, id: job_wo_skill, job: valid_params }
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
    let!(:job_wo_skill) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_w_skill) { FactoryGirl.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_skill) { FactoryGirl.create(:job_skill, job: job_w_skill, skill: skill) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
      allow(Pusher).to receive(:trigger)
    end
    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
      end
      describe 'successful update' do
        it 'has 2 jobs and 1 job skill at the start' do
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(1)
        end
        it 'add job_skill: remain 2 jobs, redirects to show, increase 1 job_skill' do
          request 
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(2)
          expect(response.status).to eq(302)
        end
        it 'remove job_skill: remain 2 jobs, redirects to show, decrease 1 job_skill' do
          expect(JobSkill.count).to eq(1)
          patch :update, id: job_w_skill.id,
                         job: valid_params.merge(job_skills_attributes: { '0' =>
                              { id: job_skill.id.to_s, _destroy: '1' } })
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(JobSkill.count).to eq(0)
          expect(response.status).to eq(302)
        end
      end
      describe 'unsuccessful update' do
        it 'unsuccessful PATCH' do
          patch :update, id: job_wo_skill.id, job: valid_params.merge(title: ' ')
          expect(response).to render_template('edit')
          expect(Job.count).to eq(2)
          expect(response.status).to eq(200)
        end
      end
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
      end
      describe 'successful update' do
        it 'has 2 jobs and 1 job skill at the start' do
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(1)
        end
        it 'add job_skill: remain 2 jobs, redirects to show, increase 1 job_skill' do
          request 
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(2)
          expect(response.status).to eq(302)
        end
        it 'remove job_skill: remain 2 jobs, redirects to show, decrease 1 job_skill' do
          expect(JobSkill.count).to eq(1)
          patch :update, id: job_w_skill.id,
                         job: valid_params.merge(job_skills_attributes: { '0' =>
                              { id: job_skill.id.to_s, _destroy: '1' } })
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(JobSkill.count).to eq(0)
          expect(response.status).to eq(302)
        end
      end
      describe 'unsuccessful update' do
        it 'unsuccessful PATCH' do
          patch :update, id: job_wo_skill.id, job: valid_params.merge(title: ' ')
          expect(response).to render_template('edit')
          expect(Job.count).to eq(2)
          expect(response.status).to eq(200)
        end
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'correct company person' do
      before(:each) do
        warden.set_user bosh_person
      end
      describe 'successful update' do
        it 'has 2 jobs and 1 job skill at the start' do
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(1)
        end
        it 'add job_skill: remain 2 jobs, redirects to show, increase 1 job_skill' do
          request 
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(Job.count).to eq(2)
          expect(JobSkill.count).to eq(2)
          expect(response.status).to eq(302)
        end
        it 'remove job_skill: remain 2 jobs, redirects to show, decrease 1 job_skill' do
          expect(JobSkill.count).to eq(1)
          patch :update, id: job_w_skill.id,
                         job: valid_params.merge(job_skills_attributes: { '0' =>
                              { id: job_skill.id.to_s, _destroy: '1' } })
          expect(response).to redirect_to(action: 'show')
          should set_flash
          expect(JobSkill.count).to eq(0)
          expect(response.status).to eq(302)
        end
      end
      describe 'unsuccessful update' do
        it 'unsuccessful PATCH' do
          patch :update, id: job_wo_skill.id, job: valid_params.merge(title: ' ')
          expect(response).to render_template('edit')
          expect(Job.count).to eq(2)
          expect(response.status).to eq(200)
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
  
  describe 'GET #update_addresses' do
    render_views
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_utah) { FactoryGirl.create(:address, state: 'Utah', location: bosh) }
    let!(:bosh_mich) { FactoryGirl.create(:address, location: bosh) }
    let(:request) { xhr :get, :update_addresses, company_id: bosh.id }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }

    context 'agency admin' do
      before(:each) do 
        warden.set_user agency_admin
        request
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
    context 'job developer' do
      before(:each) do 
        warden.set_user job_developer
        request
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
    context 'case manager' do
      it_behaves_like 'unauthorized (xhr)', 'case_manager'
    end
    context 'company person' do
      before(:each) do 
        warden.set_user bosh_person
        request
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
    context 'job seeker' do
      it_behaves_like 'unauthorized (xhr)', 'job_seeker'
    end
    context 'visitor' do
      it_behaves_like 'unauthorized (xhr)', 'visitor'
    end
  end

  describe 'DESTROY #delete' do
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:job_w_skill) { FactoryGirl.create(:job, company: bosh) }
    let(:skill) { FactoryGirl.create(:skill) }
    let!(:job_skill) { FactoryGirl.create(:job_skill, job: job_w_skill, skill: skill) }
    let(:request) { delete :destroy, id: job_w_skill }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }

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
      before(:each) do
        warden.set_user bosh_person
      end
      it 'destroys job and associated job_skill' do
        expect { delete :destroy, id: job_w_skill }.to change(Job, :count).by(-1)
      end
      it 'redirects to jobs path' do
        request
        expect(response).to redirect_to(jobs_path)
      end
      it 'set flash[:alert]' do
        request
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

  describe 'GET #show' do
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_job) { FactoryGirl.create(:job, company: bosh) }
    let(:request) { get :show, id: bosh_job }
    let(:agency_admin) { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end
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

  describe 'GET #index' do
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:bosh_job1) { FactoryGirl.create(:job, company: bosh) }
    let!(:bosh_job2) { FactoryGirl.create(:job, company: bosh) }
    let!(:rand_job1) { FactoryGirl.create(:job) }
    let!(:rand_job2) { FactoryGirl.create(:job) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    context 'company person' do
      before(:each) do 
        warden.set_user bosh_person
        get :index
      end
      it { expect(assigns(:jobs).count).to eq 2 }
      it_behaves_like 'return success and render', 'index'
    end
    context 'others' do
      before(:each) do 
        get :index
      end
      it { expect(assigns(:jobs).count).to eq 4 }
      it_behaves_like 'return success and render', 'index'
    end
  end

  describe 'GET #list_search_jobs' do
    let(:job1) do
      FactoryGirl.create(:job,
                         title: 'Customer Manager',
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
    it {expect(response).to have_http_status(:ok)}
    it {expect(response).to render_template('list_search_jobs')}
    it {expect(assigns(:title_words)).to match %w(customer manager)}
    it 'assigns description words for view' do
      expect(assigns(:description_words))
        .to match %w(responsive service)
    end
    it {expect(assigns(:jobs)[0]).to eq job1}
  end

  describe 'GET #apply' do
    let!(:job) { FactoryGirl.create(:job) }
    let!(:testfile_resume) { '/files/Janitor-Resume.doc' }
    let!(:revoked_job) { FactoryGirl.create(:job, status: 'revoked') }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let!(:job_seeker) do
      js = FactoryGirl.create(:job_seeker)
      js.assign_case_manager(FactoryGirl.create(:case_manager, agency: agency), agency)
      js.assign_job_developer(job_developer, agency)
      js
    end
    let!(:resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let(:request) { get :apply, job_id: job.id, user_id: job_seeker.id }

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download testfile_resume
    end

    describe 'unknown job' do
      before :each do
        warden.set_user job_seeker
        get :apply, job_id: 1000, user_id: job_seeker.id
      end
      it {expect(response).to redirect_to(action: 'index')}
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
      # it 'redirected to list of jobs' do
      #   expect(response).to redirect_to(action: 'index')
      # end
      it 'check set flash' do
        expect(flash[:alert]).to eq 'You are not authorized to apply. '\
        'Job has either been filled or revoked.'
      end
    end
    describe 'unknown job seeker' do
      before :each do
        warden.set_user job_developer
        get :apply, job_id: job.id, user_id: 10_000
      end
      it { expect(response).to redirect_to(action: 'show', id: job.id)}
      end
      it 'check set flash' do
        expect(flash[:alert]).to eq 'Unable to find the user who wants to apply.'
      end
    end
    context 'agency admin' do
      it_behaves_like 'unauthorized', 'agency_admin'
    end
    context 'job developer' do
      describe 'successful application' do
        before(:each) do 
          allow(Pusher).to receive(:trigger)
          allow(Event).to receive(:create).and_call_original
          warden.set_user job_developer
          request
        end
        it 'creates a job application' do
          job.reload
          expect(job.job_seekers).to include job_seeker
        end
        it 'creates :JD_APPLY event' do
          application = job.job_applications.last
          expect(Event).to have_received(:create).with(:JD_APPLY, application)
        end
        it 'show flash[:info]' do
          expect(flash[:info]).to be_present.and eq 'Job is successfully applied'\
          " for #{job_seeker.full_name}"
        end
        it  {expect(response).to redirect_to(job_path(job))}
      end
      describe "invalid application without job seeker's consent" do
        before :each do
          job_seeker.update_attribute(:consent, false)
          warden.set_user job_developer
          request
        end
        after(:each) do
          job_seeker.update_attribute(:consent, true)
        end
        it 'show flash[:alert]' do
          expect(flash[:alert]).to be_present.and eq 'You are not authorized to '\
          "apply for #{job_seeker.full_name}."
        end
        # it 'redirect to job ' do
        #   expect(response).to redirect_to(job_path(job))
        # end
      end
      describe 'duplicated application' do
        before :each do
          warden.set_user job_developer
          FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker)
          request
        end
        it 'shows flash[:alert]' do
          expect(flash[:alert]).to be_present
            .and eq "#{job_seeker.full_name(last_name_first: false)} has already "\
            'applied to this job.'
        end
        it {expect(response).to redirect_to(action: 'show', id: job.id)}
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
      describe 'successful application' do
        before :each do
          allow(Pusher).to receive(:trigger)
          allow(Event).to receive(:create).and_call_original
          stub_cruncher_authenticate
          stub_cruncher_file_download('files/Admin-Assistant-Resume.pdf')
          warden.set_user job_seeker
          request
        end
        it {expect(response).to render_template('jobs/apply')}
        it {should_not set_flash }
        it 'job should have one applicant' do
          job.reload
          expect(job.job_seekers).to include job_seeker
        end
        it 'creates :JS_APPLY event' do
          application = job.job_applications[0]
          expect(Event).to have_received(:create).with(:JS_APPLY, application)
        end
      end
      describe 'duplicated applications' do
        before :each do
          warden.set_user job_seeker
          FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker)
          request
        end
        it 'shows flash[:alert]' do
          expect(flash[:alert]).to be_present
            .and eq "#{job_seeker.full_name(last_name_first: false)} has already"\
            ' applied to this job.'
        end
        it { expect(response).to redirect_to(action: 'show', id: job.id)}
      end
    end
    context 'visitor' do
      it_behaves_like 'unauthorized', 'visitor'
    end
  end

  describe 'PATCH #revoke' do
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh', agencies: [agency]) }
    let!(:job) { FactoryGirl.create(:job, company: bosh ) }
    let!(:revoked_job) { FactoryGirl.create(:job, status: 'revoked', company: bosh) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    let(:request) { patch :revoke, id: job.id }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end
    context 'agency admin' do
      it_behaves_like 'unauthorized', 'agency_admin'
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer}
      context 'active job' do
        it 'changes job status from active to revoked' do
          request
          job.reload
          expect(job.status).to eq('revoked')
        end
        it 'creates a job_revoked event' do
          expect(Event).to receive(:create).with(:JOB_REVOKED, evt_obj(:job, :agency))
          request
        end
        it 'flash[:alert]' do
          request
          expect(flash[:alert]).to be_present.and eq "#{job.title} is revoked "\
          'successfully.'
        end
        it 'redirects to jobs_path' do
          request
          expect(response).to redirect_to(jobs_path)
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
        it {expect(response).to redirect_to(jobs_path)}
      end
    end
    context 'case manager' do
      it_behaves_like 'unauthorized', 'case_manager'
    end
    context 'company person' do
      before(:each) { warden.set_user bosh_person}
      context 'active job' do
        it 'changes job status from active to revoked' do
          request
          job.reload
          expect(job.status).to eq('revoked')
        end
        it 'creates a job_revoked event' do
          expect(Event).to receive(:create).with(:JOB_REVOKED, evt_obj(:job, :agency))
          request
        end
        it 'flash[:alert]' do
          request
          expect(flash[:alert]).to be_present.
                                and eq "#{job.title} is revoked successfully."
        end
        it 'redirects to jobs_path' do
          request
          expect(response).to redirect_to(jobs_path)
        end
      end
      context 'revoked job' do
        before :each do
          warden.set_user bosh_person
          patch :revoke, id: revoked_job.id
        end
        it 'flash[:alert]' do
          expect(flash[:alert]).to be_present.and eq 'Only active job can be revoked.'
        end
        it {expect(response).to redirect_to(jobs_path)}
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
    let!(:bosh) { FactoryGirl.create(:company, name: 'Bosh') }
    let(:bosh_person) { FactoryGirl.create(:company_person, company: bosh) }
    let!(:dyson) { FactoryGirl.create(:company, name: 'Dyson', agencies: [agency]) }
    let!(:dyson_person) { FactoryGirl.create(:company_person, company: dyson) }
    let(:request_first_page) { xhr :get, :list, job_type: 'my-company-all' }
    let(:request_last_page) { xhr :get, :list, job_type: 'my-company-all', 
                                jobs_page: 4 }
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
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
      before(:each) {  sign_in bosh_person}

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
        expect(assigns(:jobs).size).to be 1
      end

      it 'last_page: should not set flash' do
        request_last_page
        should_not set_flash
      end
    end

    describe 'company_person with 1 page' do
      before :each do
        sign_in dyson_person
        request_first_page
      end

      it { expect(response).to have_http_status(:ok)}

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
        stub_cruncher_match_resume_and_job

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker2.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message']).to eq 'No résumé on file'
      end

      it 'returns 404 status when job not in Cruncher' do
        stub_cruncher_match_resume_and_job_error(:no_job, job.id)

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No job found with id: #{job.id}"
      end

      it 'returns 404 status when resume not in Cruncher' do
        stub_cruncher_match_resume_and_job_error(:no_resume, resume.id)

        xhr :get, :match_resume, id: job.id, job_seeker_id: job_seeker.id

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No resume found with id: #{resume.id}"
      end
    end
  end
end
