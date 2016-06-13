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
    let(:company)  { FactoryGirl.create(:company) }

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
          email: 'info@widgets.com', fax:'510 555-1212').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                           '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash
        company.reload
        expect(company.email).to eq('info@widgets.com')
        expect(company.fax).to eq('510 555-1212')
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
