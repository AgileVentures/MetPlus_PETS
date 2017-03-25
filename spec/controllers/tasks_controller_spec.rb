require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  describe 'PATCH #assign' do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, agency: agency)
        @jd1 = FactoryGirl.create(:job_developer, agency: agency)
        @jd2 = FactoryGirl.create(:job_developer, agency: agency)
        @jd3 = FactoryGirl.create(:job_developer, agency: agency)
        @jd4 = FactoryGirl.create(:job_developer, agency: agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        sign_in @jd1
      end

      subject { xhr :patch, :assign, { id: @task.id }, format: :json }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    describe 'errors' do
      before :each do
        agency = FactoryGirl.create(:agency)
        @jd1 = FactoryGirl.create(:job_developer, agency: agency)
        sign_in @jd1
      end

      describe 'missing parameters' do
        subject { xhr :patch, :assign, { id: 1 }, format: :json }
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end

        it 'check content' do
          expect(subject.body)
            .to eq({ message: 'Missing assigned target' }.to_json)
        end
      end

      describe 'Cannot find task' do
        before do
          xhr :patch, :assign, { id: -1, to: 100 }, format: :json
        end

        it 'returns error' do
          expect(response).to have_http_status(403)
        end

        it 'check content' do
          expect(response.body)
            .to eq({ message: 'Cannot find the task!' }.to_json)
        end
      end

      describe 'Cannot find user' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          sign_in aa
        end

        subject do
          xhr :patch, :assign, { id: @task.id, to: 100 }, format: :json
        end
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end

        it 'check content' do
          expect(subject.body)
            .to eq({ message: 'Cannot find user!' }.to_json)
        end
      end

      describe 'Cannot assign task to user' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, agency: agency)
          @js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task @js, agency
          sign_in aa
        end

        subject do
          xhr :patch, :assign, { id: @task.id, to: @js.id }, format: :json
        end
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end

        it 'check content' do
          expect(subject.body)
            .to eq({ message: 'Cannot assign the task to that user!' }.to_json)
        end
      end
    end

    describe 'unauthorized' do
      describe 'not logged in' do
        let(:request) do
          xhr :patch, :assign, { id: @task.id, to: @js.id }, format: :json
        end
        before :each do
          agency = FactoryGirl.create(:agency)
          @js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task @js, agency
        end

        it_behaves_like 'unauthenticated XHR request'
      end
    end
  end

  describe 'PATCH #in_progress' do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, agency: agency)
        @jd1 = FactoryGirl.create(:job_developer, agency: agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        @task.assign @jd1
        sign_in @jd1
      end

      subject { xhr :patch, :in_progress, { id: @task.id }, format: :json }
      it 'returns http success' do
        expect(subject).to have_http_status(:success)
      end

      it 'check task status' do
        subject
        expect(Task.find_by_id(@task.id).status).to eq(Task::STATUS[:WIP])
      end
    end

    describe 'errors' do
      before :each do
        agency = FactoryGirl.create(:agency)
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end

      describe 'Cannot find task' do
        before do
          xhr :patch, :in_progress, { id: -1 }, format: :json
        end

        it 'returns error' do
          expect(response).to have_http_status(403)
        end

        it 'check content' do
          expect(response.body)
            .to eq({ message: 'Cannot find the task!' }.to_json)
        end
      end
    end

    describe 'unauthorized' do
      describe 'not the task owner' do
        let(:request) do
          xhr :patch, :in_progress, { id: @task.id }, format: :json
        end

        before :each do
          agency = FactoryGirl.create(:agency)
          @aa = FactoryGirl.create(:agency_admin, agency: agency)
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end

        it_behaves_like 'unauthorized XHR request' do
          let(:user) { @aa }
        end
      end

      describe 'not logged in' do
        let(:request) do
          xhr :patch, :in_progress, { id: @task.id }, format: :json
        end
        before :each do
          agency = FactoryGirl.create(:agency)
          FactoryGirl.create(:agency_admin, agency: agency)
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end

        it_behaves_like 'unauthenticated XHR request'
      end
    end
  end

  describe 'PATCH #done' do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, agency: agency)
        @jd1 = FactoryGirl.create(:job_developer, agency: agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        @task.assign @jd1
        @task.work_in_progress
        sign_in @jd1
      end

      subject { xhr :patch, :done, { id: @task.id }, format: :json }
      it 'returns http success' do
        expect(subject).to have_http_status(:success)
      end

      it 'check task status' do
        subject
        expect(Task.find_by_id(@task.id).status).to eq(Task::STATUS[:DONE])
      end
    end

    describe 'errors' do
      before :each do
        agency = FactoryGirl.create(:agency)
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end

      describe 'Cannot find task' do
        before do
          xhr :patch, :done, { id: -1 }, format: :json
        end

        it 'returns error' do
          expect(response).to have_http_status(403)
        end

        it 'check content' do
          expect(response.body)
            .to eq({ message: 'Cannot find the task!' }.to_json)
        end
      end
    end

    describe 'unauthorized' do
      describe 'not the task owner' do
        let(:request) { xhr :patch, :done, { id: @task.id }, format: :json }
        before :each do
          agency = FactoryGirl.create(:agency)
          FactoryGirl.create(:agency_admin, agency: agency)
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          @jd2 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end

        it_behaves_like 'unauthorized XHR request' do
          let(:user) { @jd2 }
        end
      end

      describe 'not logged in' do
        let(:request) { xhr :patch, :done, { id: @task.id }, format: :json }
        before :each do
          agency = FactoryGirl.create(:agency)
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end

        it_behaves_like 'unauthenticated XHR request'
      end
    end
  end

  describe 'GET #tasks' do
    describe 'unauthorized' do
      let(:request) do
        xhr :get, :tasks, { task_type: 'mine-open' }, format: :json
      end
      context 'not signed in' do
        it_behaves_like 'unauthenticated XHR request'
      end

      context 'job seeker' do
        it_behaves_like 'unauthorized XHR request' do
          let(:user) { FactoryGirl.create(:job_seeker) }
        end
      end
    end
  end

  describe 'GET #list_owners' do
    let!(:agency) { FactoryGirl.create(:agency) }
    describe 'authorized access' do
      before :each do
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end

      describe 'retrieve information' do
        before :each do
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          @jd2 = FactoryGirl.create(:job_developer, agency: agency)
          @jd3 = FactoryGirl.create(:job_developer, agency: agency)
          @jd4 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
        end

        subject { xhr :get, :list_owners, { id: @task.id }, format: :json }
        it 'returns http success' do
          expect(subject).to have_http_status(:success)
        end

        it 'check content' do
          expect(JSON.parse(subject.body))
            .to eq('results' =>
                        [
                          { 'id' => @jd1.id,
                            'text' => @jd1.full_name },
                          { 'id' => @jd2.id,
                            'text' => @jd2.full_name },
                          { 'id' => @jd3.id,
                            'text' => @jd3.full_name },
                          { 'id' => @jd4.id,
                            'text' => @jd4.full_name }
                        ])
        end
      end

      describe 'unknown task' do
        subject { xhr :get, :list_owners, { id: -1000 }, format: :json }
        it 'returns http error' do
          expect(subject).to have_http_status(403)
        end

        it 'check content' do
          expect(subject.body)
            .to eq({ message: 'Cannot find the task!' }.to_json)
        end
      end

      describe 'no assignable found' do
        before :each do
          @jd1 = FactoryGirl.create(:job_developer, agency: agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_cm_task js, agency
        end

        subject { xhr :get, :list_owners, { id: @task.id }, format: :json }
        it 'returns http success' do
          expect(subject).to have_http_status(403)
        end

        it 'check content' do
          expect(subject.body).to eq({
            message: 'There are no users you can assign this task to!'
          }.to_json)
        end
      end
    end

    describe 'Unauthorized access' do
      let(:company) { FactoryGirl.create(:company) }
      let(:company_contact) do
        FactoryGirl.create(:company_contact, company: company)
      end
      let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
      let(:case_manager) { FactoryGirl.create(:case_manager, agency: agency) }
      let(:job_seeker) { FactoryGirl.create(:job_seeker) }
      let(:request) { xhr :get, :list_owners, { id: @task.id }, format: :json }
      before :each do
        @task = Task.new_js_unassigned_jd_task job_seeker, agency
      end

      context 'not logged in' do
        it_behaves_like 'unauthenticated XHR request'
      end

      context 'Job Seeker' do
        it_behaves_like 'unauthorized XHR request' do
          let(:user) { job_seeker }
        end
      end

      context 'Case Manager' do
        it_behaves_like 'unauthorized XHR request' do
          let(:user) { case_manager }
        end
      end

      context 'Job Developer' do
        it_behaves_like 'unauthorized XHR request' do
          let(:user) { job_developer }
        end
      end

      context 'Company Contact' do
        it_behaves_like 'unauthorized XHR request' do
          let(:user) { company_contact }
        end
      end
    end
  end
end
