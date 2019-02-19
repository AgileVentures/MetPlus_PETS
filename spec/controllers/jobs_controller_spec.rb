require 'rails_helper'
include ServiceStubHelpers::Cruncher
include ServiceStubHelpers::EmailValidator

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
  let(:agency) { FactoryBot.create(:agency) }
  let(:agency_admin) { FactoryBot.create(:agency_admin, agency: agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let!(:bosh) { FactoryBot.create(:company, name: 'Bosh', agencies: [agency]) }
  let!(:bosh_utah) { FactoryBot.create(:address, state: 'Utah', location: bosh) }
  let!(:bosh_mich) { FactoryBot.create(:address, location: bosh) }
  let(:bosh_job) { FactoryBot.create(:job, company: bosh, address: bosh_utah) }
  let(:bosh_person) { FactoryBot.create(:company_contact, company: bosh) }
  let(:skill) { FactoryBot.create(:skill) }
  let!(:license)  { FactoryBot.create(:license) }
  let!(:question) { FactoryBot.create(:question) }

  let!(:valid_params) do
    { title: 'Ruby on Rails', description: 'passionate',
      company_id: bosh.id, address_id: bosh_mich.id, shift: 'Evening',
      company_job_id: 'WERRR123',
      job_skills_attributes: { '0' => { skill_id: skill.id,
                                        required: 1,
                                        min_years: 2,
                                        max_years: 5,
                                        _destroy: false } } }
  end

  let(:new_address_params) do
    { new_address_attributes: { street: 'new street', city: 'new city',
                                state: 'Michigan', zipcode: '12345' } }
  end

  let(:new_license_params) do
    { job_licenses_attributes: { '0' => { license_id: 1, _destroy: false } } }
  end

  let(:new_question_params) do
    { job_questions_attributes: { '0' => { question_id: 1, _destroy: false } } }
  end

  let(:job_seeker) do
    js = FactoryBot.create(:job_seeker)
    FactoryBot.create(:resume, job_seeker: js)
    bosh_job.apply js
    js
  end
  let!(:test_file) { '../fixtures/files/Admin-Assistant-Resume.pdf' }
  let!(:stub) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    stub_cruncher_job_update
    stub_cruncher_file_download test_file
    stub_cruncher_match_resumes
    stub_email_validate_valid
    allow(Pusher).to receive(:trigger)
  end

  describe 'GET #index' do
    context 'search by title and description' do
      let(:job1) do
        FactoryBot.create(:job, title: 'Customer Manager',
                                description: 'Provide resposive customer service')
      end
      let(:job2) { FactoryBot.create(:job) }
      let!(:job_skill1) do
        FactoryBot.create(:job_skill,
                          job: job1,
                          skill: FactoryBot.create(:skill, name: 'New Skill 1'))
      end
      let!(:job_skill2) do
        FactoryBot.create(:job_skill,
                          job: job2,
                          skill: FactoryBot.create(:skill, name: 'New Skill 2'))
      end
      before(:each) do
        get :index,
            params: {
              q: { 'title_cont_any': 'customer manager',
                   'description_cont_any': 'responsive service' }
            }
      end
      it_behaves_like 'return success and render', 'index'
      it { expect(assigns(:title_words)).to match %w[customer manager] }
      it 'assigns description words for view' do
        expect(assigns(:description_words)).to match %w[responsive service]
      end
      it { expect(assigns(:jobs)[0]).to eq job1 }
    end
    context 'only active company jobs are returned' do
      let!(:skill_s) { FactoryBot.create(:skill, name: 'Search Skill') }
      let!(:joba) do
        FactoryBot.create(:job,
                          company: FactoryBot.create(:company, name: 'Active inc',
                                                               status: 'active',
                                                               agencies: [agency]))
      end
      let!(:job_skilla) do
        FactoryBot.create(:job_skill,
                          job: joba,
                          skill: skill_s)
      end
      let!(:jobp) do
        FactoryBot.create(:job,
                          company: FactoryBot.create(:company,
                                                     name: 'Pending inc',
                                                     status: 'pending_registration',
                                                     agencies: [agency]))
      end
      let!(:job_skillp) do
        FactoryBot.create(:job_skill,
                          job: jobp,
                          skill: skill_s)
      end
      let!(:jobi) do
        FactoryBot.create(:job,
                          company: FactoryBot.create(:company,
                                                     name: 'Inact inc',
                                                     status: 'inactive',
                                                     agencies: [agency]))
      end
      let!(:job_skilli) do
        FactoryBot.create(:job_skill,
                          job: jobi,
                          skill: skill_s)
      end
      let!(:jobd) do
        FactoryBot.create(:job,
                          company: FactoryBot.create(:company,
                                                     name: 'Denied inc',
                                                     status: 'registration_denied',
                                                     agencies: [agency]))
      end
      let!(:job_skilld) do
        FactoryBot.create(:job_skill,
                          job: jobd,
                          skill: skill_s)
      end
      it 'Only active company jobs are listed in the initial display' do
        get :index
        expect(assigns(:jobs)).to eq [joba]
      end
      it 'Search on skill only returns active company jobs' do
        get :index,
            params: {
              q: { 'skills_id_in': [skill_s.id.to_s] }
            }
        expect(assigns(:jobs)).to eq [joba]
      end
    end

    context 'when company person is logged in' do
      let!(:skill_s) { FactoryBot.create(:skill, name: 'Search Skill') }
      let!(:other_inc) do
        FactoryBot.create(:company, name: 'Other inc',
                                    status: 'active',
                                    agencies: [agency])
      end

      let!(:job_1_widget_company) { FactoryBot.create(:job, company: bosh) }
      let!(:job_1_other_company) { FactoryBot.create(:job, company: other_inc) }
      let!(:job_2_other_company) { FactoryBot.create(:job, company: other_inc) }

      it 'show jobs only of the current company' do
        sign_in bosh_person
        get :index
        expect(assigns(:jobs)).to eq [job_1_widget_company]
      end
    end
  end

  describe 'GET #new' do
    let(:widget) { FactoryBot.create(:company, name: 'Widget', agencies: [agency]) }
    let!(:dyson) { FactoryBot.create(:company, name: 'Dyson', agencies: [agency]) }
    let(:request) { get :new, params: { company_id: widget.id } }

    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
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
    let(:request) { post :create, params: { job: valid_params } }

    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      describe 'successful POST #create' do
        it 'change job & job skill count by 1' do
          expect { post :create, params: { job: valid_params } }
            .to change(Job, :count).by(1).and change(JobSkill, :count).by(1)
        end
        it 'redirects to the job show view' do
          request
          expect(response).to redirect_to(job_path(Job.last))
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
      end
      describe 'unsuccessful POST #create' do
        it 'does not change job & job skills count' do
          expect { post :create, params: { job: valid_params.merge(title: ' ') } }
            .to change(Job, :count).by(0).and change(Job, :count).by(0)
        end
        it 'return success and render new' do
          post :create, params: { job: valid_params.merge(title: ' ') }
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
        it 'changes job & job skill count by 1' do
          expect { post :create, params: { job: valid_params } }
            .to change(Job, :count).by(1).and change(JobSkill, :count).by(1)
        end

        it 'redirects to the job show view' do
          request
          expect(response).to redirect_to(job_path(Job.last))
          expect(flash[:notice]).to eq "#{valid_params[:title]} " \
                                       'has been created successfully.'
        end
        context 'when additional licenses are present' do
          it 'saves the additional license' do
            post :create, params: {
              job: valid_params.merge(
                additional_licenses: 'Some additional licenses text'
              )
            }
            expect(Job.first.additional_licenses).to eq 'Some additional licenses text'
          end
        end
        context 'when additional skills are present' do
          it 'saves the additional skills' do
            post :create, params: {
              job: valid_params.merge(
                additional_skills: 'Some additional skills text'
              )
            }
            expect(Job.first.additional_skills).to eq 'Some additional skills text'
          end
        end
      end

      describe 'create job with new address' do
        it 'changes Address count by 1' do
          expect { post :create, params: { job: valid_params.merge(new_address_params) } }
            .to change(Address, :count).by(1)
        end
      end

      describe 'create job with new license' do
        it 'changes JobLicense count by 1' do
          expect { post :create, params: { job: valid_params.merge(new_license_params) } }
            .to change(JobLicense, :count).by(1)
        end
      end

      describe 'create job with new question' do
        it 'changes JobQuestion count by 1' do
          expect do
            post :create, params: {
              job: valid_params.merge(new_question_params)
            }
          end
            .to change(JobQuestion, :count).by(1)
        end
      end

      describe 'unsuccessful POST #create' do
        it 'does not change job & job skill count' do
          expect { post :create, params: { job: valid_params.merge(title: ' ') } }
            .to change(Job, :count).by(0).and change(Job, :count).by(0)
        end
        it 'return success and render new' do
          post :create, params: { job: valid_params.merge(title: ' ') }
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
    let(:request) { get :show, params: { id: bosh_job } }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }

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
    let(:request) { get :edit, params: { id: bosh_job } }

    context 'agency admin' do
      before(:each) do
        warden.set_user agency_admin
        request
      end
      it { expect(assigns(:addresses)).to eq bosh.addresses.order(:state) }
      it_behaves_like 'return success and render', 'edit'
    end
    context 'job developer' do
      before(:each) do
        warden.set_user job_developer
        request
      end
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
    let(:request) { patch :update, params: { id: job_wo_skill, job: valid_params } }
    let!(:job_wo_skill) { FactoryBot.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_w_skill) { FactoryBot.create(:job, company: bosh, address: bosh_mich) }
    let!(:job_skill) { FactoryBot.create(:job_skill, job: job_w_skill, skill: skill) }

    context 'agency admin' do
      before(:each) { warden.set_user agency_admin }
      describe 'successful update' do
        it 'add job_skill: remain job count, increase 1 job_skill' do
          expect { patch :update, params: { id: job_wo_skill, job: valid_params } }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, params: {
              id: job_w_skill.id,
              job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
            }
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
          expect do
            patch :update, params: {
              id: job_wo_skill, job: valid_params.merge(title: ' ')
            }
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, params: { id: job_wo_skill, job: valid_params.merge(title: ' ') }
          expect(response).to have_http_status(:success)
          expect(response).to render_template 'edit'
        end
      end
    end
    context 'job developer' do
      before(:each) { warden.set_user job_developer }
      describe 'successful update' do
        it 'add job_skill: remain job count, increase 1 job_skill' do
          expect { patch :update, params: { id: job_wo_skill, job: valid_params } }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, params: {
              id: job_w_skill.id,
              job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
            }
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
          expect do
            patch :update, params: {
              id: job_wo_skill, job: valid_params.merge(title: ' ')
            }
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, params: { id: job_wo_skill, job: valid_params.merge(title: ' ') }
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
          expect { patch :update, params: { id: job_wo_skill, job: valid_params } }
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(1)
        end
        it 'remove job_skill: remain job count, decrease 1 job_skill' do
          expect do
            patch :update, params: {
              id: job_w_skill.id,
              job: valid_params.merge(job_skills_attributes: { '0' =>
                        { id: job_skill.id.to_s, _destroy: '1' } })
            }
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(-1)
        end

        describe 'updates job with new license' do
          it 'changes JobLicense count by 1' do
            expect do
              patch :update, params: {
                id: job_wo_skill.id,
                job: valid_params.merge(new_license_params)
              }
            end
              .to change(JobLicense, :count).by(1)
          end
        end

        describe 'updates job with new question' do
          it 'changes JobQuestion count by 1' do
            expect do
              patch :update, params: {
                id: job_wo_skill.id,
                job: valid_params.merge(new_question_params)
              }
            end
              .to change(JobQuestion, :count).by(1)
          end
        end

        it 'redirects to show, show flash' do
          request
          expect(response).to redirect_to(action: 'show')
          expect(flash[:info]).to eq "#{valid_params[:title]} "\
                                     'has been updated successfully.'
        end

        context 'when additional licenses are present' do
          it 'saves the additional license' do
            patch :update, params: {
              id: job_wo_skill.id,
              job: valid_params.merge(
                additional_licenses: 'Some additional licenses text'
              )
            }
            expect(Job.first.additional_licenses).to eq 'Some additional licenses text'
          end
        end

        context 'when additional skills are present' do
          it 'saves the additional skill' do
            patch :update, params: {
              id: job_wo_skill.id,
              job: valid_params.merge(
                additional_skills: 'Some additional skills text'
              )
            }
            expect(Job.first.additional_skills).to eq 'Some additional skills text'
          end
        end
      end
      describe 'unsuccessful update' do
        it 'remain job & job skill count' do
          expect do
            patch :update, params: {
              id: job_wo_skill, job: valid_params.merge(title: ' ')
            }
          end
            .to change { Job.count }.by(0).and change { JobSkill.count }.by(0)
        end
        it 'return success and render edit' do
          patch :update, params: {
            id: job_wo_skill, job: valid_params.merge(title: ' ')
          }
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
    let!(:job_w_skill) { FactoryBot.create(:job, company: bosh) }
    let!(:job_skill) { FactoryBot.create(:job_skill, job: job_w_skill, skill: skill) }
    let(:request) { delete :destroy, params: { id: job_w_skill } }

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
        expect do
          delete :destroy, params: {
            id: job_w_skill
          }
        end
          .to change(Job, :count).by(-1)
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
    let!(:dyson) { FactoryBot.create(:company, name: 'Dyson', agencies: [agency]) }
    let!(:dyson_person) { FactoryBot.create(:company_person, company: dyson) }
    let(:request_first_page) do
      get :list, params: { job_type: 'my-company-all' }, xhr: true
    end
    let(:request_last_page) do
      get :list, params: { job_type: 'my-company-all', page: 4 }, xhr: true
    end
    let(:request_recent_jobs) do
      get :list, params: { job_type: 'recent-jobs' }, xhr: true
    end
    before(:each) do
      31.times.each do |i|
        title = i < 10 ? "Awesome job 0#{i}" : "Awesome job #{i}"
        FactoryBot.create(:job, title: title, company: bosh,
                                company_person: bosh_person)
      end
      4.times.each do |i|
        FactoryBot.create(:job, title: "Awesome new job #{i}", company: dyson,
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
      it { expect(response).to render_template('jobs/_list_jobs') }
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

    describe 'company_person with recent jobs filter' do
      before :each do
        warden.set_user dyson_person
        request_recent_jobs
      end

      it 'recent_jobs: is a success' do
        expect(response).to have_http_status(:ok)
      end

      it "recent_jobs: renders 'jobs/_list_jobs' template" do
        expect(response).to render_template('jobs/_list_jobs')
      end

      it 'recent_jobs: check_jobs' do
        expect(assigns(:jobs).first.title).to eq 'Awesome new job 3'
      end
    end
  end

  describe 'GET #update_addresses' do
    render_views
    before(:each) do
      warden.set_user agency_admin
      get :update_addresses, params: { company_id: bosh.id }, xhr: true
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
    let!(:revoked_job) { FactoryBot.create(:job, status: 'revoked') }
    let!(:job_seeker) do
      js = FactoryBot.create(:job_seeker)
      js.assign_case_manager(FactoryBot.create(:case_manager, agency: agency), agency)
      js.assign_job_developer(job_developer, agency)
      js
    end
    let!(:resume) do
      stub_cruncher_file_upload
      FactoryBot.create(:resume, job_seeker: job_seeker)
    end
    let(:request) { get :apply, params: { job_id: bosh_job.id, user_id: job_seeker.id } }

    describe 'unknown job' do
      before :each do
        warden.set_user job_seeker
        get :apply, params: { job_id: 1000, user_id: job_seeker.id }
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
        get :apply, params: { job_id: revoked_job.id, user_id: job_seeker.id }
      end
      it 'check set flash' do
        expect(flash[:alert]).to eq 'You are not authorized to apply. '\
        'Job has either been filled or revoked.'
      end
    end
    describe 'unknown job seeker' do
      before :each do
        warden.set_user job_developer
        get :apply, params: { job_id: bosh_job.id, user_id: 10_000 }
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
      end
      describe 'duplicated application' do
        before :each do
          FactoryBot.create(:job_application, job: bosh_job, job_seeker: job_seeker)
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
          FactoryBot.create(:job_application, job: bosh_job, job_seeker: job_seeker)
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
    let!(:revoked_job) { FactoryBot.create(:job, status: 'revoked', company: bosh) }
    let(:request) { patch :revoke, params: { id: bosh_job.id } }

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
          patch :revoke, params: { id: revoked_job.id }
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
          patch :revoke, params: { id: revoked_job.id }
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

    let(:job_seeker)  { FactoryBot.create(:job_seeker) }
    let(:job_seeker2) { FactoryBot.create(:job_seeker) }
    let!(:resume) do
      stub_cruncher_file_upload
      FactoryBot.create(:resume, job_seeker: job_seeker)
    end
    let(:job)         { FactoryBot.create(:job) }
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
      stub_cruncher_file_upload
    end

    context 'happy path' do
      before(:each) do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job
        get :match_resume, params: { id: job.id, job_seeker_id: job_seeker.id }, xhr: true
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

        get :match_resume, params: { id: job.id, job_seeker_id: job_seeker2.id },
                           xhr: true

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message']).to eq 'No résumé on file'
      end

      it 'returns 404 status when job not in Cruncher' do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job_error(:no_job, job.id)

        get :match_resume, params: { id: job.id, job_seeker_id: job_seeker.id }, xhr: true

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No job found with id: #{job.id}"
      end

      it 'returns 404 status when resume not in Cruncher' do
        warden.set_user job_seeker
        stub_cruncher_match_resume_and_job_error(:no_resume, resume.id)

        get :match_resume, params: { id: job.id, job_seeker_id: job_seeker.id }, xhr: true

        expect(JSON.parse(response.body)['status']).to eq 404
        expect(JSON.parse(response.body)['message'])
          .to eq "No resume found with id: #{resume.id}"
      end
    end
  end

  describe 'GET #match_jd_job_seekers' do
    let(:job_seeker_ids) { [1, 2, 3, 4] }
    let(:request) do
      get :match_jd_job_seekers, params: {
        id: bosh_job.id,
        job_seeker_ids: job_seeker_ids
      }
    end

    before(:each) do
      stub_cruncher_file_upload
    end

    context 'happy path' do
      context 'non-nil job-seeker ids' do
        let(:results) { double('results') }
        let(:sorted_results) { double('sorted_results') }

        before do
          warden.set_user job_developer
          stub_cruncher_match_resume_and_job
          allow(controller).to receive(:get_matches).with(job_seeker_ids)
                                                    .and_return(results)
          allow(described_class).to receive(:sort_by_score).with(results)
                                                           .and_return(sorted_results)
        end

        it 'calls sort_by_score' do
          expect(described_class).to receive(:sort_by_score).with(results)
          request
        end

        it 'assigns an instance variable' do
          request
          expect(assigns(:match_results)).to eq(sorted_results)
        end

        it 'renders the template' do
          request
          expect(response).to render_template(:match_jd_job_seekers)
        end
      end

      context 'nil job-seeker ids' do
        let(:request) { get :match_jd_job_seekers, params: { id: bosh_job.id } }

        before do
          warden.set_user job_developer
          request
        end

        it 'redirects to the job show view' do
          expect(response).to redirect_to(job_path(bosh_job))
        end

        it 'sets the flash' do
          expect(flash[:alert]).to eq('Please choose a job seeker')
        end
      end
    end

    context 'sad path' do
      context 'agency admin' do
        it_behaves_like 'unauthorized request' do
          let(:user) { agency_admin }
        end
      end

      context 'case manager' do
        it_behaves_like 'unauthorized request' do
          let(:user) { FactoryBot.create(:case_manager, agency: agency) }
        end
      end

      context 'company person' do
        it_behaves_like 'unauthorized request' do
          let(:user) { bosh_person }
        end
      end

      context 'company contact' do
        it_behaves_like 'unauthorized request' do
          let(:user) { FactoryBot.create(:company_contact, company: bosh) }
        end
      end

      context 'job seeker' do
        it_behaves_like 'unauthorized request' do
          let(:user) { FactoryBot.create(:job_seeker) }
        end
      end
    end
  end

  describe 'GET #match_job_seekers' do
    let(:cmpy_contact) { FactoryBot.create(:company_contact) }
    8.times do |n|
      let("js#{n + 1}".to_sym) { FactoryBot.create(:job_seeker) }
    end

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_file_upload
    end

    context 'happy path' do
      before(:each) do
        FactoryBot.create(:resume, job_seeker: js1)
        FactoryBot.create(:resume, job_seeker: js2)
        FactoryBot.create(:resume, job_seeker: js3)
        FactoryBot.create(:resume, job_seeker: js4)
        FactoryBot.create(:resume, job_seeker: js5)
        FactoryBot.create(:resume, job_seeker: js6)
        FactoryBot.create(:resume, job_seeker: js7)
        FactoryBot.create(:resume, job_seeker: js8)

        bosh_job.apply js2
        bosh_job.apply js5
        bosh_job.apply js8

        warden.set_user bosh_person
        get :match_job_seekers, params: { id: bosh_job.id }
      end

      it 'starts and stops spinner' do
        expect(Pusher).to have_received(:trigger)
          .with('pusher_control',
                'spinner_start',
                user_id: bosh_person.user.id,
                target: '.table.table-bordered')
        expect(Pusher).to have_received(:trigger)
          .with('pusher_control',
                'spinner_stop',
                user_id: bosh_person.user.id,
                target: '.table.table-bordered')
      end
      it 'sets match array if matches found' do
        expect(assigns(:job_matches))
          .to match_array([[js7, 4.9, false], [js5, 3.8, true],
                           [js2, 2.0, true],  [js8, 1.8, true],
                           [js6, 1.7, false]])
      end
    end

    context 'sad path' do
      before(:each) do
        warden.set_user bosh_person
      end
      it 'sets flash and redirects if job ID not found' do
        stub_cruncher_match_resumes_fail('JOB_NOT_FOUND')
        get :match_job_seekers, params: { id: bosh_job.id }

        expect(flash[:alert])
          .to eq 'No matching job seekers found.'
        expect(response).to redirect_to(job_path(bosh_job.id))
      end
      it 'sets flash and redirects if resume not found' do
        get :match_job_seekers, params: { id: bosh_job.id }

        expect(flash[:alert])
          .to eq "Error: Couldn't find Resume with 'id'=7"
        expect(response).to redirect_to(job_path(bosh_job.id))
      end
      it 'sets flash and redirects if job seeker not found' do
        8.times do
          FactoryBot.create(:resume)
        end
        job_seeker = Resume.find(7).job_seeker
        job_seeker.delete # use 'delete' to prevent destroying associated objects

        get :match_job_seekers, params: { id: bosh_job.id }

        expect(flash[:alert])
          .to eq "Error: Couldn't find JobSeeker for Resume with 'id' = 7"
        expect(response).to redirect_to(job_path(bosh_job.id))
      end
    end

    context 'authorization' do
      let(:request) { get :match_job_seekers, params: { id: bosh_job.id } }
      let(:user)    { FactoryBot.create(:company_contact) }

      describe 'visitor' do
        it_behaves_like 'unauthorized', 'visitor'
      end
      describe 'job seeker' do
        it_behaves_like 'unauthorized', 'job_seeker'
      end
      describe 'case manager' do
        it_behaves_like 'unauthorized', 'case_manager'
      end
      describe 'company person - wrong company' do
        it_behaves_like 'unauthorized request'
      end
    end
  end

  describe 'GET #notify_job_developer' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_file_upload
    end
    context 'happy path' do
      before(:each) do
        allow(Event).to receive(:create).and_call_original
        warden.set_user bosh_person
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: job_developer.id,
          company_person_id: bosh_person.id,
          job_seeker_id: job_seeker.id
        }, xhr: true
      end

      it 'creates CP_INTEREST_IN_JS event' do
        expect(Event).to have_received(:create)
          .with(:CP_INTEREST_IN_JS, evt_obj(:job, :company_person,
                                            :job_developer, :job_seeker))
      end
      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'sad path' do
      before(:each) do
        warden.set_user bosh_person
      end
      it 'returns 404 if company_person not found' do
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: job_developer.id,
          company_person_id: 0,
          job_seeker_id: job_seeker.id
        }, xhr: true
      end
      it 'returns 404 if job_developer not found' do
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: 0,
          company_person_id: bosh_person.id,
          job_seeker_id: job_seeker.id
        }, xhr: true
      end
      it 'returns 404 if job_seeker not found' do
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: job_developer.id,
          company_person_id: bosh_person.id,
          job_seeker_id: 0
        }, xhr: true
      end
    end

    context 'authentication' do
      let(:request) do
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: job_developer.id,
          company_person_id: bosh_person.id,
          job_seeker_id: job_seeker.id
        }, xhr: true
      end

      describe 'not logged in' do
        it_behaves_like 'unauthenticated XHR request'
      end
    end

    context 'authorization' do
      let(:request) do
        get :notify_job_developer, params: {
          id: bosh_job.id,
          job_developer_id: job_developer.id,
          company_person_id: bosh_person.id,
          job_seeker_id: job_seeker.id
        }, xhr: true
      end

      describe 'job seeker' do
        it_behaves_like 'unauthorized XHR', 'job_seeker'
      end
      describe 'case manager' do
        it_behaves_like 'unauthorized XHR', 'case_manager'
      end
      describe 'company person - wrong company' do
        it_behaves_like 'unauthorized XHR', 'company_person'
      end
    end
  end
end
