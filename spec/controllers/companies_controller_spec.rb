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

  describe "PATCH #update" do

    before(:each) do
      @company = FactoryGirl.create(:company)
    end

    context 'valid attributes' do
      it 'locates the requested company' do
        patch :update, id: @company, company: attributes_for(:company)
        expect(assigns(:company)).to eq(@company)
      end

      it 'changes the company attributes' do
        patch :update, id: @company, company: attributes_for(:company,
          email: 'info@widgets.com')
        @company.reload
        expect(@company.email).to eq('info@widgets.com')
      end

    end

  end

end
