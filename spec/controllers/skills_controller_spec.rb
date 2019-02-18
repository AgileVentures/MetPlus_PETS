require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'unauthorized access' do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }

  context 'Not logged in' do
    it_behaves_like 'unauthenticated XHR request'
  end

  context 'Case Manager' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:case_manager, agency: agency) }
    end
  end

  context 'Job Developer' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:job_developer, agency: agency) }
    end
  end
  context 'Job Seeker' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:job_seeker) }
    end
  end
end

RSpec.describe SkillsController, type: :controller do
  let(:agency)               { FactoryBot.create(:agency) }
  let(:skill_params)         { FactoryBot.attributes_for(:skill) }
  let(:company)              { FactoryBot.create(:company) }
  let(:skill_params_company) { skill_params.merge(company_id: company.id.to_s) }
  let(:skill)                { FactoryBot.create(:skill) }
  let(:company_skill) do
    skill = FactoryBot.create(:skill, name: 'company_skill')
    skill.organization = company
    skill.save
    skill
  end

  describe 'POST #create' do
    context 'authorized access - agency admin' do
      before :each do
        aa = FactoryBot.create(:agency_admin, agency: agency)
        sign_in aa
      end
      it 'creates new skill for valid parameters' do
        expect { post :create, params: { skill: skill_params }, xhr: true }
          .to change(Skill, :count).by(+1)
      end

      it 'returns success for valid parameters' do
        post :create, params: { skill: skill_params }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        post :create, params: { skill: { name: '', description: '' } }, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    context 'authorized access - company admin' do
      before :each do
        ca = FactoryBot.create(:company_admin, company: company)
        sign_in ca
      end

      it 'creates new skill for valid parameters' do
        expect { post :create, params: { skill: skill_params_company }, xhr: true }
          .to change(Skill, :count).by(+1)
      end

      it 'returns success for valid parameters' do
        post :create, params: { skill: skill_params_company }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        post :create, params: { skill: { name: '', description: '' } }, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    context 'authorized access - company contact' do
      before :each do
        cc = FactoryBot.create(:company_contact, company: company)
        sign_in cc
      end
      it 'creates new skill for valid parameters' do
        expect { post :create, params: { skill: skill_params_company }, xhr: true }
          .to change(Skill, :count).by(+1)
      end

      it 'returns success for valid parameters' do
        post :create, params: { skill: skill_params_company }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        post :create, params: { skill: { name: '', description: '' } }, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    it_behaves_like 'unauthorized access' do
      let(:request) { post :create, params: { skill: skill_params }, xhr: true }
    end
  end

  describe 'GET #show' do
    context 'authorized access - agency admin' do
      before :each do
        aa = FactoryBot.create(:agency_admin, agency: agency)
        sign_in aa
      end
      context 'skill found' do
        before(:each) do
          get :show, params: { id: skill }, xhr: true
        end

        it 'renders json structure' do
          expect(JSON.parse(response.body))
            .to match('id' => skill.id,
                      'name' => skill.name,
                      'description' => skill.description)
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          get :show, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'authorized access - company admin' do
      before :each do
        ca = FactoryBot.create(:company_admin, company: company)
        sign_in ca
      end
      context 'skill found' do
        before(:each) do
          get :show, params: { id: company_skill }, xhr: true
        end

        it 'renders json structure' do
          expect(JSON.parse(response.body))
            .to match('id' => company_skill.id,
                      'name' => company_skill.name,
                      'description' => company_skill.description)
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          get :show, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'authorized access - company contact' do
      before :each do
        cc = FactoryBot.create(:company_contact, company: company)
        sign_in cc
      end
      context 'skill found' do
        before(:each) do
          get :show, params: { id: company_skill }, xhr: true
        end

        it 'renders json structure' do
          expect(JSON.parse(response.body))
            .to match('id' => company_skill.id,
                      'name' => company_skill.name,
                      'description' => company_skill.description)
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          get :show, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like 'unauthorized access' do
      let(:request) { get :show, params: { id: skill }, xhr: true }
    end
  end

  describe 'PATCH #update' do
    context 'authorized access - agency admin' do
      before :each do
        aa = FactoryBot.create(:agency_admin, agency: agency)
        sign_in aa
      end
      it 'returns success for valid parameters' do
        patch :update, params: { id: skill, skill: skill_params }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        patch :update,
              params: { id: skill, skill: { name: '', description: '' } }, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    context 'authorized access - company admin' do
      before :each do
        ca = FactoryBot.create(:company_admin, company: company)
        sign_in ca
      end
      it 'returns success for valid parameters' do
        patch :update, params: { id: company_skill, skill: skill_params }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        patch :update,
              params: { id: company_skill, skill: { name: '', description: '' } },
              xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    context 'authorized access - company contact' do
      before :each do
        cc = FactoryBot.create(:company_contact, company: company)
        sign_in cc
      end
      it 'returns success for valid parameters' do
        patch :update, params: { id: company_skill, skill: skill_params }, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        patch :update,
              params: { id: company_skill, skill: { name: '', description: '' } },
              xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    it_behaves_like 'unauthorized access' do
      let(:request) do
        patch :update, params: { id: skill, skill: skill_params }, xhr: true
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context 'authorized access - agency admin' do
      before :each do
        aa = FactoryBot.create(:agency_admin, agency: agency)
        sign_in aa
      end

      let!(:job_skill) { FactoryBot.create(:job_skill, skill: skill) }

      context 'skill found' do
        let(:request) { delete :destroy, params: { id: skill }, xhr: true }
        it 'deletes skill' do
          expect { request }
            .to change(Skill, :count).by(-1)
        end
        it 'deletes associated job_skill' do
          expect { request }
            .to change(JobSkill, :count).by(-1)
        end
        it 'returns http success' do
          request
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          delete :destroy, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'authorized access - company admin' do
      before :each do
        ca = FactoryBot.create(:company_admin, company: company)
        sign_in ca
      end

      let!(:job_skill) { FactoryBot.create(:job_skill, skill: company_skill) }

      context 'skill found' do
        let(:request) { delete :destroy, params: { id: company_skill }, xhr: true }

        it 'deletes skill' do
          expect { request }
            .to change(Skill, :count).by(-1)
        end
        it 'deletes associated job_skill' do
          expect { request }
            .to change(JobSkill, :count).by(-1)
        end
        it 'returns http success' do
          request
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          delete :destroy, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'authorized access - company contact' do
      before :each do
        cc = FactoryBot.create(:company_contact, company: company)
        sign_in cc
      end

      let!(:job_skill) { FactoryBot.create(:job_skill, skill: company_skill) }

      context 'skill found' do
        let(:request) { delete :destroy, params: { id: company_skill }, xhr: true }

        it 'deletes skill' do
          expect { request }
            .to change(Skill, :count).by(-1)
        end
        it 'deletes associated job_skill' do
          expect { request }
            .to change(JobSkill, :count).by(-1)
        end
        it 'returns http success' do
          request
          expect(response).to have_http_status(:success)
        end
      end

      context 'skill NOT found' do
        it 'returns http status not_found' do
          delete :destroy, params: { id: 0 }, xhr: true
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like 'unauthorized access' do
      let(:request) { delete :destroy, params: { id: 0 }, xhr: true }
    end
  end

  describe 'Call action outside of XHR request' do
    let!(:skill)  { FactoryBot.create(:skill) }

    it 'raises an exception' do
      expect { get :show, params: { id: skill } }.to raise_error(RuntimeError)
    end
  end
end
