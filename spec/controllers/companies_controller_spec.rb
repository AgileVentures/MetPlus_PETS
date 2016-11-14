require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:company)   { FactoryGirl.create(:company) }
  let(:company_admin) { FactoryGirl.create(:company_admin, company: company) }
 
  before(:each) do
    sign_in company_admin
  end

  describe "GET #show" do
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

  describe 'GET #list_people' do
    
    let!(:cp1) { FactoryGirl.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp3) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp4) { FactoryGirl.create(:company_contact, company: company) }

    before(:each) do
      sign_in cp1
      xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
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

  describe "PATCH #update" do
   
    let(:hash_params) do
      company.attributes.merge(addresses_attributes:
                      {'0' => attributes_for(:address)})
    end

    context 'valid attributes' do

      it 'locates the requested company' do
        patch :update, id: company, company: hash_params
        expect(assigns(:company)).to eq(company)
      end

      it 'changes the company attributes' do
        params_hash = attributes_for(:company,
          email: 'info@widgets.com', fax:'510 555-1212',
          job_email: 'humanresources@widgets.com').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                           '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash
        company.reload
        expect(company.email).to eq('info@widgets.com')
        expect(company.fax).to eq('510 555-1212')
        expect(company.job_email).to eq('humanresources@widgets.com')
        expect(company.addresses.count).to eq 2
      end
      it 'deletes company address' do
        hash_params[:addresses_attributes]['0']['_destroy'] = true

        patch :update, id: company, company: hash_params
        company.reload
        expect(company.addresses.count).to eq 0
      end
    end
  end

end
