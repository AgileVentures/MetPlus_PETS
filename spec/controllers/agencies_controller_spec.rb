require 'rails_helper'

RSpec.describe AgenciesController, type: :controller do

  describe "GET #edit" do
    context 'success' do
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
    context "as Job Developer" do
      before(:each) do
        @agency = FactoryGirl.create(:agency)
        job_developer = FactoryGirl.create(:job_developer, agency: @agency)
        sign_in job_developer
        get :edit, id: @agency
      end
      it "redirect" do
        expect(response).to have_http_status 302
      end
      it 'sets flash message' do
        expect(flash[:alert]).to eq "You are not authorized to edit #{@agency.name} agency."
      end
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
      render_views

      before(:each) do
        @agency = FactoryGirl.create(:agency)
        @agency.assign_attributes(phone: '', website: 'nodomain')
        @agency.valid?
        agency_admin = FactoryGirl.create(:agency_admin, agency: @agency)
        sign_in agency_admin
        patch :update, agency: FactoryGirl.attributes_for(:agency,
                        phone: '', website: 'nodomain'), id: @agency
      end
      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it 'renders partial for errors' do
        expect(response).to render_template(partial: 'shared/_error_messages')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
    describe "Try to edit as Job Developer" do
      before(:each) do
        @agency = FactoryGirl.create(:agency)
        job_developer = FactoryGirl.create(:job_developer, agency: @agency)
        sign_in job_developer
        patch :update, agency: FactoryGirl.attributes_for(:agency,
                                                          phone: '', website: 'nodomain'), id: @agency
      end
      it "redirect" do
        expect(response).to have_http_status 302
      end
      it 'sets flash message' do
        expect(flash[:alert]).to eq "You are not authorized to edit #{@agency.name} agency."
      end
    end
  end
end
