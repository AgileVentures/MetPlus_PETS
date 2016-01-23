require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  describe "GET #show" do
    let(:company)   { FactoryGirl.create(:company) }
    before(:each) do
      get :show, id: company
    end
    it 'assigns @company for view' do
      expect(assigns(:company)).to eq company
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do

    let(:company)  { FactoryGirl.create(:company) }

    before(:each) do
      get :edit, id: company
    end
    it 'assigns @company for form' do
      expect(assigns(:company)).to eq company
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end
