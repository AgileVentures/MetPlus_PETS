require 'rails_helper'

RSpec.describe JobCategoriesController, type: :controller do

  describe "POST #create" do
    let(:jobcat_params) { FactoryGirl.attributes_for(:job_category) }

    it 'creates new job category for valid parameters' do
      expect { xhr :post, :create, job_category: jobcat_params }.
        to change(JobCategory, :count).by(+1)
    end
    it 'returns success for valid parameters' do
      xhr :post, :create, job_category: jobcat_params
      expect(response).to have_http_status(:success)
    end

    it 'returns errors and error status for invalid parameters' do
      xhr :post, :create, job_category: {name: '', description: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template('shared/_error_messages')
    end
  end

  describe "GET #edit" do
    let(:category)  { FactoryGirl.create(:job_category) }

    context 'job category found' do
      before(:each) do
        xhr :get, :edit, id: category
      end

      it 'renders json structure' do
        expect(JSON.parse(response.body))
            .to match({'id' => category.id,
                       'name' => category.name,
                       'description' => category.description})
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'job category NOT found' do
      it "returns http status not_found" do
        xhr :get, :edit, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH #update" do
    let(:category)  { FactoryGirl.create(:job_category) }
    let(:jobcat_params) { FactoryGirl.attributes_for(:job_category) }

    it 'returns success for valid parameters' do
      xhr :patch, :update, id: category, job_category: jobcat_params
      expect(response).to have_http_status(:success)
    end

    it 'returns errors and error status for invalid parameters' do
      xhr :patch, :update, id: category, job_category: {name: '', description: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template('shared/_error_messages')
    end
  end

  describe "DELETE #destroy" do
    let!(:category)  { FactoryGirl.create(:job_category) }

    context 'job category found' do

      it 'deletes job category' do
        expect { xhr :delete, :destroy, id: category }.
            to change(JobCategory, :count).by(-1)
      end
      it "returns http success" do
        xhr :delete, :destroy, id: category
        expect(response).to have_http_status(:success)
      end
    end

    context 'job category NOT found' do
      it "returns http status not_found" do
        xhr :delete, :destroy, id: 0
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
