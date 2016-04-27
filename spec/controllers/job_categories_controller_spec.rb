require 'rails_helper'

RSpec.describe JobCategoriesController, type: :controller do

  let(:s1) { FactoryGirl.create(:skill, name: 'test1') }
  let(:s2) { FactoryGirl.create(:skill, name: 'test2') }
  let(:s3) { FactoryGirl.create(:skill, name: 'test3') }
  let(:s4) { FactoryGirl.create(:skill, name: 'test4') }

  let(:skill_ids) { [s1.id, s2.id, s3.id, s4.id] }

  describe "POST #create" do

    let(:jobcat_params) do
      params = FactoryGirl.attributes_for(:job_category)
      params[:skill_ids] = skill_ids
      params
    end

    it 'creates new job category for valid parameters' do
      expect { xhr :post, :create, job_category: jobcat_params }.
        to change(JobCategory, :count).by(+1)
    end
    it 'creates new category<>skill associations' do
      xhr :post, :create, job_category: jobcat_params
      expect(JobCategory.find(1).skills.count).to eq 4
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

  describe "GET #show" do
    let(:category)  { FactoryGirl.create(:job_category) }

    context 'job category found' do
      before(:each) do
        category.skills = [s1, s2, s3, s4]
        xhr :get, :show, id: category
      end

      it 'renders json structure' do
        expect(JSON.parse(response.body))
            .to match({'id' => category.id,
                       'name' => category.name,
                       'description' => category.description,
                       'skills' => [
                         {'id' => s1.id, 'name' => s1.name},
                         {'id' => s2.id, 'name' => s2.name},
                         {'id' => s3.id, 'name' => s3.name},
                         {'id' => s4.id, 'name' => s4.name}
                         ] })
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'job category NOT found' do
      it "returns http status not_found" do
        xhr :get, :show, id: 0
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
