require 'rails_helper'

RSpec.describe TasksController, type: :controller do

  describe "PATCH #assign" do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, :agency => agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd2 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd3 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd4 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        sign_in @jd1
      end
      subject{xhr :patch, :assign , {id: @task.id}, :format => :json}
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
    describe 'errors' do
      before :each do
        agency = FactoryGirl.create(:agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        sign_in @jd1
      end
      describe 'missing parameters' do
        subject{xhr :patch, :assign , {id: 1}, :format => :json}
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end
        it 'check content' do
          expect(subject.body).to eq({:message => 'Missing assigned target'}.to_json)
        end
      end
      describe 'Cannot find task' do
        it 'returns error' do
          xhr :patch, :assign , {id: -1, to: 100}, :format => :json
          expect(response).to have_http_status(403)
        end
        it 'check content' do
          xhr :patch, :assign , {id: -1, to: 100}, :format => :json
          expect(response.body).to eq({:message => 'Cannot find the task!'}.to_json)
        end
      end
      describe 'Cannot find user' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, :agency => agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          sign_in aa
        end
        subject{xhr :patch, :assign , {id: @task.id, to: 100}, :format => :json}
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end
        it 'check content' do
          expect(subject.body).to eq({:message => 'Cannot find user!'}.to_json)
        end
      end
      describe 'Cannot assign task to user' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, :agency => agency)
          @js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task @js, agency
          sign_in aa
        end
        subject{xhr :patch, :assign , {id: @task.id, to: @js.id}, :format => :json}
        it 'returns error' do
          expect(subject).to have_http_status(403)
        end
        it 'check content' do
          expect(subject.body).to eq({:message => 'Cannot assign the task to that user!'}.to_json)
        end
      end
      end
    describe 'unauthorized' do
      describe 'not logged in' do
        before :each do
          agency = FactoryGirl.create(:agency)
          @js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task @js, agency
        end
        subject{xhr :patch, :assign , {id: @task.id, to: @js.id}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(401)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You need to login to perform this action.'}.to_json)
        end
      end
    end
  end

  describe 'PATCH #in_progress' do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, :agency => agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        @task.assign @jd1
        sign_in @jd1
      end
      subject{xhr :patch, :in_progress , {id: @task.id}, :format => :json}
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
        aa = FactoryGirl.create(:agency_admin, :agency => agency)
        sign_in aa
      end
      describe 'Cannot find task' do
        it 'returns error' do
          xhr :patch, :in_progress , {id: -1}, :format => :json
          expect(response).to have_http_status(403)
        end
        it 'check content' do
          xhr :patch, :in_progress , {id: -1}, :format => :json
          expect(response.body).to eq({:message => 'Cannot find the task!'}.to_json)
        end
      end
    end
    describe 'unauthorized' do
      describe 'not the task owner' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, :agency => agency)
          @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
          sign_in aa
        end
        subject{xhr :patch, :in_progress , {id: @task.id}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(403)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You are not authorized to perform this action.'}.to_json)
        end
      end
      describe 'not logged in' do
        before :each do
          agency = FactoryGirl.create(:agency)
          aa = FactoryGirl.create(:agency_admin, :agency => agency)
          @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end
        subject{xhr :patch, :in_progress , {id: @task.id}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(401)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You need to login to perform this action.'}.to_json)
        end
      end
    end
  end

  describe 'PATCH #done' do
    describe 'successful' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, :agency => agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
        @task.assign @jd1
        @task.work_in_progress
        sign_in @jd1
      end
      subject{xhr :patch, :done , {id: @task.id}, :format => :json}
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
        aa = FactoryGirl.create(:agency_admin, :agency => agency)
        sign_in aa
      end
      describe 'Cannot find task' do
        it 'returns error' do
          xhr :patch, :done , {id: -1}, :format => :json
          expect(response).to have_http_status(403)
        end
        it 'check content' do
          xhr :patch, :done , {id: -1}, :format => :json
          expect(response.body).to eq({:message => 'Cannot find the task!'}.to_json)
        end
      end
    end
    describe 'unauthorized' do
      describe 'not the task owner' do
        before :each do
          agency = FactoryGirl.create(:agency)
          FactoryGirl.create(:agency_admin, :agency => agency)
          @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
          @jd2 = FactoryGirl.create(:job_developer, :agency => agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
          sign_in @jd2
        end
        subject{xhr :patch, :done , {id: @task.id}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(403)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You are not authorized to perform this action.'}.to_json)
        end
      end
      describe 'not logged in' do
        before :each do
          agency = FactoryGirl.create(:agency)
          @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
          js = FactoryGirl.create(:job_seeker)
          @task = Task.new_js_unassigned_jd_task js, agency
          @task.assign @jd1
        end
        subject{xhr :patch, :done , {id: @task.id}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(401)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You need to login to perform this action.'}.to_json)
        end
      end
    end
  end
  describe 'GET #tasks' do
    describe 'unauthorized' do
      context 'not signed in' do
        subject{xhr :get, :tasks , {:task_type => 'mine-open'}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(401)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You need to login to perform this action.'}.to_json)
        end
      end
      context 'job seeker' do
        before :each do
          js = FactoryGirl.create(:job_seeker)
          sign_in js
        end
        subject{xhr :get, :tasks , {:task_type => 'mine-open'}, :format => :json}
        it 'returns http error' do
          expect(subject).to have_http_status(403)
        end
        it 'check task status' do
          subject
          expect(response.body).to eq({:message => 'You are not authorized to perform this action.'}.to_json)
        end
      end
    end
  end
  describe 'GET #list_owners' do
    let!(:agency){FactoryGirl.create(:agency)}
    before :each do
      aa = FactoryGirl.create(:agency_admin, :agency => agency)
      sign_in aa
    end
    describe 'retrieve information' do
      before :each do
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd2 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd3 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd4 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
      end
      subject{xhr :get, :list_owners , {id: @task.id}, :format => :json}
      it 'returns http success' do
        expect(subject).to have_http_status(:success)
      end
      it 'check content' do
        expect(JSON.parse(subject.body)).to eq({'results' => [
                                                   {'id' => @jd1.id,
                                                    'text' => @jd1.full_name},
                                                   {'id' => @jd2.id,
                                                    'text' => @jd2.full_name},
                                                   {'id' => @jd3.id,
                                                    'text' => @jd3.full_name},
                                                   {'id' => @jd4.id,
                                                    'text' => @jd4.full_name}]})
      end
    end
    describe 'unknown task' do
      subject{xhr :get, :list_owners , {id: -1000}, :format => :json}
      it 'returns http error' do
        expect(subject).to have_http_status(403)
      end
      it 'check content' do
        expect(subject.body).to eq({:message => 'Cannot find the task!'}.to_json)
      end
    end
    describe 'no assignable found' do
      before :each do
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_cm_task js, agency
      end

      subject{xhr :get, :list_owners , {id: @task.id}, :format => :json}

      it 'returns http success' do
        expect(subject).to have_http_status(403)
      end
      it 'check content' do
        expect(subject.body).to eq({:message => 'There are no users you can assign this task to!'}.to_json)
      end
    end
  end

  describe 'Unauthorized access' do
    before :each do
      js = FactoryGirl.create(:job_seeker)
      @task = Task.new_js_unassigned_jd_task js, agency
    end
    context "not logged in" do
      subject{xhr :get, :list_owners , {id: @task.id}, :format => :json}
      it 'returns http unauthorized' do
        expect(subject).to have_http_status(403)
      end
      it 'check content' do
        expect(subject.body).to eq({:message => 'You are not authorized to perform this action.'}.to_json)
      end
    end
  end
end
