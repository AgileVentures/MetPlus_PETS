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
          email: 'info@widgets.com', fax:'510 555-1212')
        @company.reload
        expect(@company.email).to eq('info@widgets.com')
        expect(@company.fax).to eq('510 555-1212')
      end
    end
  end

  describe 'GET #list_people' do
    let(:company) { FactoryGirl.create(:company) }

    let!(:cp1) { FactoryGirl.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp3) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp4) { FactoryGirl.create(:company_contact, company: company) }

    before(:each) do
      sign_in cp1
      xhr :get, :list_people, id: company.id, people_type: 'my-company-all'
    end
    it 'assigns @people to collection of all company people' do
      expect(assigns(:people)).to include cp1, cp2, cp3, cp4
    end
    it 'renders company_people/list_people template' do
      expect(response).to render_template('company_people/_list_people')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end
