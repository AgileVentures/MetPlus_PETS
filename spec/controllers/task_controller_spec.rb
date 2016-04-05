require 'rails_helper'

RSpec.describe TaskController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #assign" do
    it "returns http success" do
      get :assign
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #in_progress" do
    it "returns http success" do
      get :in_progress
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #done" do
    it "returns http success" do
      get :done
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #list_owners" do
    describe 'retrieve information' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, :agency => agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd2 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd3 = FactoryGirl.create(:job_developer, :agency => agency)
        @jd4 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_jd_task js, agency
      end
      subject{xhr :get, :list_owners , {id: @task.id}, :format => :json}
      it "returns http success" do
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
      it "returns http error" do
        expect(subject).to have_http_status(401)
      end
      it 'check content' do
        expect(subject.body).to eq({:message => 'Cannot find the task!'}.to_json)
      end
    end
    describe 'no assignable found' do
      before :each do
        agency = FactoryGirl.create(:agency)
        FactoryGirl.create(:agency_admin, :agency => agency)
        @jd1 = FactoryGirl.create(:job_developer, :agency => agency)
        js = FactoryGirl.create(:job_seeker)
        @task = Task.new_js_unassigned_cm_task js, agency
      end
      subject{xhr :get, :list_owners , {id: @task.id}, :format => :json}
      it "returns http success" do
        expect(subject).to have_http_status(401)
      end
      it 'check content' do
        expect(subject.body).to eq({:message => 'There are no users you can assign this task to!'}.to_json)
      end
    end
  end
end
