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

  describe "PATCH #update" do
    xit "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end

end
