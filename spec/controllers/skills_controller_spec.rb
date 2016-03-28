require 'rails_helper'

RSpec.describe SkillsController, type: :controller do

  describe "POST #create" do
    let(:skill_params) { FactoryGirl.attributes_for(:skill) }

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

  describe "GET #edit" do
    let(:skill)  { FactoryGirl.create(:skill) }

    context 'skill found' do
      before(:each) do
        xhr :get, :edit, id: skill
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
        xhr :get, :edit, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH #update" do
    let(:skill)  { FactoryGirl.create(:skill) }
    let(:skill_params) { FactoryGirl.attributes_for(:skill) }

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

  describe "DELETE #destroy" do
    let!(:skill)  { FactoryGirl.create(:skill) }

    context 'skill found' do

      it 'deletes skill' do
        expect { xhr :delete, :destroy, id: skill }.
            to change(Skill, :count).by(-1)
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

  describe 'Call action outside of XHR request' do
    let!(:skill)  { FactoryGirl.create(:skill) }

    it 'raises an exception' do
      expect {get :edit, id: skill}.to raise_error(RuntimeError)
    end
  end
end
