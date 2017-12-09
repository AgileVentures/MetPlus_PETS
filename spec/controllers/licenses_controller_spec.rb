require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'LicensesController unauthorized access' do
  let(:agency) { FactoryBot.create(:agency) }

  context 'Not logged in' do
    it_behaves_like 'unauthenticated XHR request'
  end

  context 'Case Manager' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:case_manager, agency: agency) }
    end
  end

  context 'Job Developer' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:job_developer, agency: agency) }
    end
  end
  context 'Job Seeker' do
    it_behaves_like 'unauthorized XHR request' do
      let(:user) { FactoryBot.create(:job_seeker) }
    end
  end
end

RSpec.describe LicensesController, type: :controller do
  let(:agency)          { FactoryBot.create(:agency) }
  let(:agency_admin)    { FactoryBot.create(:agency_admin, agency: agency) }
  let(:license_params)  { FactoryBot.attributes_for(:license) }
  let(:license)         { FactoryBot.create(:license) }

  describe 'POST #create' do
    context 'authorized access - agency admin' do
      before :each do
        sign_in agency_admin
      end
      it 'creates new license for valid parameters' do
        expect { xhr :post, :create, license: license_params }
          .to change(License, :count).by(+1)
      end

      it 'returns success for valid parameters' do
        xhr :post, :create, license: license_params
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        xhr :post, :create, license: { abbr: '', title: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    it_behaves_like 'LicensesController unauthorized access' do
      let(:request) { xhr :post, :create, license: license_params }
    end
  end

  describe 'GET #show' do
    context 'authorized access - agency admin' do
      before :each do
        sign_in agency_admin
      end

      context 'license found' do
        before(:each) do
          xhr :get, :show, id: license
        end

        it 'renders json structure' do
          expect(JSON.parse(response.body))
            .to match('id' => license.id,
                      'abbr' => license.abbr,
                      'title' => license.title)
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'license NOT found' do
        it 'returns http status not_found' do
          xhr :get, :show, id: 0
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like 'LicensesController unauthorized access' do
      let(:request) { xhr :get, :show, id: license }
    end
  end

  describe 'PATCH #update' do
    context 'authorized access - agency admin' do
      before :each do
        sign_in agency_admin
      end
      it 'returns success for valid parameters' do
        xhr :patch, :update, id: license, license: license_params
        expect(response).to have_http_status(:success)
      end

      it 'returns errors and error status for invalid parameters' do
        xhr :patch, :update, id: license, license: { abbr: '', title: '' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('shared/_error_messages')
      end
    end

    it_behaves_like 'LicensesController unauthorized access' do
      let(:request) { xhr :patch, :update, id: license, license: license_params }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context 'authorized access - agency admin' do
      before :each do
        sign_in agency_admin
      end

      let!(:job_license) { FactoryBot.create(:job_license, license: license) }

      context 'license found' do
        let(:request) { xhr :delete, :destroy, id: license }

        it 'deletes license' do
          expect { request }.to change(License, :count).by(-1)
        end
        it 'deletes associated job_license' do
          expect { request }.to change(JobLicense, :count).by(-1)
        end
        it 'returns http success' do
          request
          expect(response).to have_http_status(:success)
        end
      end

      context 'license NOT found' do
        it 'returns http status not_found' do
          xhr :delete, :destroy, id: 0
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    it_behaves_like 'LicensesController unauthorized access' do
      let(:request) { xhr :delete, :destroy, id: 0 }
    end
  end

  describe 'Call action outside of XHR request' do
    it 'raises an exception' do
      license
      expect { get :show, id: license }.to raise_error(RuntimeError)
    end
  end
end
