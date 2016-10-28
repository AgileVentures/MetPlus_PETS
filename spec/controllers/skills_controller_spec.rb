require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples "unauthorized" do
  before :each do
    warden.set_user user
  end
  subject{my_request}
  it 'returns http unauthorized' do
    expect(subject).to have_http_status(403)
  end
  it 'check content' do
    expect(subject.body).to eq({:message => 'You are not authorized to perform this action.'}.to_json)
  end
end

RSpec.shared_examples "unauthorized all" do
  let(:agency) {FactoryGirl.create(:agency)}
  let(:company) {FactoryGirl.create(:company)}
  context "Not logged in" do
    subject{my_request}
    it 'returns http unauthorized' do
      expect(subject).to have_http_status(401)
    end
    it 'check content' do
      expect(subject.body).to eq({:message => 'You need to login to perform this action.'}.to_json)
    end
  end
  context "Case Manager" do
    it_behaves_like "unauthorized" do
      let(:user) {FactoryGirl.create(:case_manager, agency: agency)}
    end
  end
  context "Job Developer" do
    it_behaves_like "unauthorized" do
      let(:user) {FactoryGirl.create(:job_developer, agency: agency)}
    end
  end
  context "Job Seeker" do
    it_behaves_like "unauthorized" do
      let(:user) {FactoryGirl.create(:job_seeker)}
    end
  end
  context "Company admin" do
    it_behaves_like "unauthorized" do
      let(:user) {FactoryGirl.create(:company_admin, company: company)}
    end
  end
  context "Company contact" do
    it_behaves_like "unauthorized" do
      let(:user) {FactoryGirl.create(:company_contact, company: company)}
    end
  end
end

RSpec.describe SkillsController, type: :controller do

  describe "POST #create" do
    let(:agency) {FactoryGirl.create(:agency)}
    let(:skill_params) { FactoryGirl.attributes_for(:skill) }
    context "authorized access" do
      before :each do
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end
      it 'creates new skill for valid parameters' do
        expect { xhr :post, :create, skill: skill_params }.
          to change(Skill, :count).by(+1)
      end
      it 'returns success for valid parameters' do
        xhr :post, :create, skill: skill_params
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        xhr :post, :create, skill: {name: '', description: ''}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end
    it_behaves_like "unauthorized all" do
      let(:my_request) {xhr :post, :create, skill: skill_params}
    end
  end

  describe "GET #show" do
    let(:agency) {FactoryGirl.create(:agency)}
    let(:skill)  { FactoryGirl.create(:skill) }
    context "authorized access" do
      before :each do
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end
      context 'skill found' do
        before(:each) do
          xhr :get, :show, id: skill
        end

        it 'renders json structure' do
          expect(JSON.parse(response.body))
              .to match({'id' => skill.id,
                         'name' => skill.name,
                         'description' => skill.description})
        end
        it "returns http success" do
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it "returns http status not_found" do
          xhr :get, :show, id: 0
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like "unauthorized all" do
      let(:my_request) {xhr :get, :show, id: skill}
    end
  end

  describe "PATCH #update" do
    let(:agency) {FactoryGirl.create(:agency)}
    let(:skill)  { FactoryGirl.create(:skill) }
    let(:skill_params) { FactoryGirl.attributes_for(:skill) }
    context "authorized access" do
      before :each do
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end
      it 'returns success for valid parameters' do
        xhr :patch, :update, id: skill, skill: skill_params
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        xhr :patch, :update, id: skill, skill: {name: '', description: ''}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end
    it_behaves_like "unauthorized all" do
      let(:my_request) {xhr :patch, :update, id: skill, skill: skill_params}
    end
  end

  describe "DELETE #destroy" do

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context "authorized access" do
      let(:agency) {FactoryGirl.create(:agency)}
      before :each do
        aa = FactoryGirl.create(:agency_admin, agency: agency)
        sign_in aa
      end
      let(:skill)     { FactoryGirl.create(:skill) }
      let!(:job_skill) { FactoryGirl.create(:job_skill, skill: skill)}

      context 'skill found' do

        it 'deletes skill' do
          expect { xhr :delete, :destroy, id: skill }.
              to change(Skill, :count).by(-1)
        end
        it 'deletes associated job_skill' do
          expect { xhr :delete, :destroy, id: skill }.
              to change(JobSkill, :count).by(-1)
        end
        it "returns http success" do
          xhr :delete, :destroy, id: skill
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it "returns http status not_found" do
          xhr :delete, :destroy, id: 0
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like "unauthorized all" do
      let(:my_request) {  xhr :delete, :destroy, id: 0}
    end
  end

  describe 'Call action outside of XHR request' do
    let!(:skill)  { FactoryGirl.create(:skill) }

    it 'raises an exception' do
      expect {get :show, id: skill}.to raise_error(RuntimeError)
    end
  end
end
