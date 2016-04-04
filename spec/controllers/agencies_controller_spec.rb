require 'rails_helper'

RSpec.describe AgenciesController, type: :controller do

  describe "GET #edit" do
    before(:each) do
      @agency = FactoryGirl.create(:agency)
      agency_admin = FactoryGirl.create(:agency_admin, agency: @agency)
      sign_in agency_admin
      get :edit, id: @agency
    end
    it 'assigns @agency for form' do
      expect(assigns(:agency)).to eq @agency
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET #edit as" do
    before(:each) do
    end
    it " Job Developer Fail" do
      @agency = FactoryGirl.create(:agency)
      agency_admin = FactoryGirl.create(:job_developer, agency: @agency)
      sign_in agency_admin
      expect{get :edit, id: @agency}.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "PATCH #update" do
    context 'valid attributes' do
      before(:each) do
        @agency = FactoryGirl.create(:agency)
        agency_admin = FactoryGirl.create(:agency_admin, agency: @agency)
        sign_in agency_admin
        patch :update, agency: FactoryGirl.attributes_for(:agency),
                     id: @agency
      end
      it 'assigns @agency for updating' do
        expect(assigns(:agency)).to eq @agency
      end
      it 'returns redirect status' do
        expect(response).to have_http_status 302
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq "Agency was successfully updated."
      end
      it 'redirects to agency admin home' do
        expect(response).to redirect_to(agency_admin_home_path)
      end
    end
    context 'invalid attributes' do
      before(:each) do
        @agency = FactoryGirl.create(:agency)
        agency_admin = FactoryGirl.create(:agency_admin, agency: @agency)
        sign_in agency_admin
        @agency.assign_attributes(phone: '', website: 'nodomain')
        @agency.valid?
        patch :update, agency: FactoryGirl.attributes_for(:agency, 
                        phone: '', website: 'nodomain'), id: @agency
      end
      it 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).to eq @agency.errors.full_messages
      end
      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
