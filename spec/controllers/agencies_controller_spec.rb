require 'rails_helper'

RSpec.describe AgenciesController, type: :controller do
  let!(:agency)       { FactoryBot.create(:agency) }
  let(:agency_admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }

  describe 'GET #edit' do
    context 'success' do
      before(:each) do
        sign_in agency_admin
        get :edit, params: { id: agency }
      end
      it 'assigns agency for form' do
        expect(assigns(:agency)).to eq agency
      end
      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
    context 'as Job Developer' do
      before(:each) do
        sign_in job_developer
        get :edit, params: { id: agency }
      end
      it 'redirect' do
        expect(response).to have_http_status 302
      end
      it 'sets flash message' do
        expect(flash[:alert])
          .to eq "You are not authorized to edit #{agency.name} agency."
      end
    end
  end

  describe 'PATCH #update' do
    context 'valid attributes' do
      before(:each) do
        sign_in agency_admin
        patch :update, params: { agency: FactoryBot.attributes_for(:agency),
                                 id: agency }
      end
      it 'assigns @agency for updating' do
        expect(assigns(:agency)).to eq agency
      end
      it 'returns redirect status' do
        expect(response).to have_http_status 302
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Agency was successfully updated.'
      end
      it 'redirects to agency admin home' do
        expect(response).to redirect_to(agency_admin_home_path)
      end
    end
    context 'invalid attributes' do
      render_views

      before(:each) do
        sign_in agency_admin
        patch :update, params: { agency: FactoryBot.attributes_for(
          :agency,
          phone: '',
          website: 'nodomain'
        ), id: agency }
      end
      it 'renders edit template' do
        expect(response).to render_template('edit')
      end
      it 'renders partial for errors' do
        expect(response).to render_template(partial: 'shared/_error_messages')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'action authorization' do
    context '.edit' do
      it 'authorizes agency_admin' do
        expect(subject).to_not receive(:user_not_authorized)
        sign_in agency_admin
        get :edit, params: { id: agency.id }
      end
      it 'does not authorize non-admin user' do
        sign_in job_developer
        get :edit, params: { id: agency.id }
        expect(flash[:alert])
          .to eq "You are not authorized to edit #{agency.name} agency."
      end
    end

    context '.update' do
      it 'authorizes agency_admin' do
        expect(subject).to_not receive(:user_not_authorized)
        sign_in agency_admin
        patch :update, params: { agency: FactoryBot.attributes_for(:agency),
                                 id: agency }
      end
      it 'does not authorize non-admin user' do
        sign_in job_developer
        patch :update, params: { agency: FactoryBot.attributes_for(:agency),
                                 id: agency }
        expect(flash[:alert])
          .to eq "You are not authorized to edit #{agency.name} agency."
      end
    end
  end
end
