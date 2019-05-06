require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.shared_examples 'unauthorized company people' do
  let(:company) { FactoryBot.create(:company) }

  context 'company admin' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:company_admin, company: company) }
    end
  end

  context 'company contact' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:company_contact, company: company) }
    end
  end
end

RSpec.shared_examples 'unauthorized agency people and jobseeker' do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }

  context 'Case manager' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:case_manager, agency: agency) }
    end
  end

  context 'Job developer' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:job_developer, agency: agency) }
    end
  end

  context 'Job seeker' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:job_seeker) }
    end
  end
end

RSpec.describe CompaniesController, type: :controller do
  let(:agency) { FactoryBot.create(:agency) }
  let(:admin) { FactoryBot.create(:agency_admin, agency: agency) }
  let(:company) { FactoryBot.create(:company, agencies: [agency]) }
  let(:company_with_jobs) do
    FactoryBot.create(:company, agencies: [agency], jobs: [FactoryBot.create(:job)])
  end
  let(:company_admin) { FactoryBot.create(:company_admin, company: company) }
  let(:company_contact) { FactoryBot.create(:company_contact, company: company) }
  let(:jd)     { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm)     { FactoryBot.create(:case_manager, agency: agency) }
  let(:js)     { FactoryBot.create(:job_seeker) }

  describe 'GET #show' do
    before(:each) do
      sign_in company_admin
      get :show, params: { id: company }
    end
    it 'assigns @company for view' do
      expect(assigns(:company)).to eq company
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    before(:each) do
      sign_in company_admin
      get :edit, params: { id: company }
    end
    it 'assigns @company for form' do
      expect(assigns(:company)).to eq company
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      sign_in admin

      subject.destroy_company_iterator = double
      expect(subject.destroy_company_iterator).to receive(:call)
        .with(company.id.to_s)
        .and_return(company)

      delete :destroy, params: { id: company }
    end

    it 'shows the flash notice message' do
      expect(flash[:notice]).to eq("Company '#{company.name}' deleted.")
    end

    it 'redirects to root path' do
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET #list_people' do
    let!(:cp1) { FactoryBot.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryBot.create(:company_contact, company: company) }
    let!(:cp3) { FactoryBot.create(:company_contact, company: company) }
    let!(:cp4) { FactoryBot.create(:company_contact, company: company) }

    before(:each) do
      sign_in cp1
      get :list_people, params: { id: company }, xhr: true
    end
    it 'assigns @people to collection of all company people' do
      expect(assigns(:people)).to include cp1, cp2, cp3, cp4
    end
    it 'renders company_people/list_people template' do
      expect(response).to render_template('company_people/_list_people')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:hash_params) do
      company.attributes.merge(addresses_attributes:
                      { '0' => attributes_for(:address) })
    end

    before(:each) do
      sign_in company_admin
    end

    context 'valid attributes' do
      it 'locates the requested company' do
        patch :update, params: { id: company, company: hash_params }
        expect(assigns(:company)).to eq(company)
      end

      it 'changes the company attributes' do
        params_hash = attributes_for(:company,
                                     email: 'info@widgets.com', fax: '510 555-1212',
                                     job_email: 'humanresources@widgets.com')
                      .merge(addresses_attributes:
                          { '0' => attributes_for(:address),
                            '1' => attributes_for(:address) })

        patch :update, params: { id: company, company: params_hash }
        company.reload
        expect(company.email).to eq('info@widgets.com')
        expect(company.fax).to eq('510 555-1212')
        expect(company.job_email).to eq('humanresources@widgets.com')
        expect(company.addresses.count).to eq 2
      end
      it 'deletes company address' do
        hash_params[:addresses_attributes]['0']['_destroy'] = true

        patch :update, params: { id: company, company: hash_params }
        company.reload
        expect(company.addresses.count).to eq 0
      end
    end
  end

  describe 'action authorization' do
    context '#edit' do
      it 'authorizes company admin' do
        allow(controller).to receive(:current_user).and_return(company_admin)
        get :edit, params: { id: company }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :edit, params: { id: company }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized agency people and jobseeker' do
        let(:request) { get :edit, params: { id: company } }
      end
      it_behaves_like 'unauthorized request' do
        let(:request) { get :edit, params: { id: company } }
        let(:user) { company_contact }
      end
    end
    context '#update' do
      let(:params_hash) do
        attributes_for(:company,
                       email: 'info@widgets.com', fax: '510 555-1212',
                       job_email: 'humanresources@widgets.com')
          .merge(addresses_attributes:
                        { '0' => attributes_for(:address),
                          '1' => attributes_for(:address) })
      end

      it 'authorizes company admin' do
        patch :update, params: { id: company, company: params_hash }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency admin' do
        patch :update, params: { id: company, company: params_hash }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized agency people and jobseeker' do
        let(:request) do
          patch :update, params: { id: company, company: params_hash }
        end
        it_behaves_like 'unauthorized request' do
          let(:request) { patch :update, params: { id: company, company: params_hash } }
          let(:user) { company_contact }
        end
      end
    end

    context '#show' do
      it 'authorizes company admin' do
        allow(controller).to receive(:current_user).and_return(company_admin)
        get :show, params: { id: company }
        expect(subject).to_not receive(:user_not_authorized)
      end

      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :show, params: { id: company }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized agency people and jobseeker' do
        let(:request) { get :show, params: { id: company } }
      end
      it_behaves_like 'unauthorized request' do
        let(:request) { get :show, params: { id: company } }
        let(:user) { company_contact }
      end
    end
    context '#destroy' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        delete :destroy, params: { id: company }
        expect(subject).to_not receive(:user_not_authorized)
      end

      it_behaves_like 'unauthorized agency people and jobseeker' do
        let(:request) { delete :destroy, params: { id: company } }
      end

      it_behaves_like 'unauthorized company people' do
        let(:request) { delete :destroy, params: { id: company } }
      end
    end
    context '#list-people' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :list_people, params: { id: company }, xhr: true
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes company admin' do
        allow(controller).to receive(:current_user).and_return(company_admin)
        get :list_people, params: { id: company }, xhr: true
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes company contact' do
        allow(controller).to receive(:current_user).and_return(company_contact)
        get :list_people, params: { id: company }, xhr: true
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'denies access to job developer' do
        allow(controller).to receive(:current_user).and_return(jd)
        get :list_people, params: { id: company }, xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
              'You are not authorized to view the people.')
      end
      it 'denies access to case manager' do
        allow(controller).to receive(:current_user).and_return(cm)
        get :list_people, params: { id: company }, xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
              'You are not authorized to view the people.')
      end
      it 'denies access to job seeker' do
        allow(controller).to receive(:current_user).and_return(js)
        get :list_people, params: { id: company }, xhr: true
        expect(response).to have_http_status 403
        expect(JSON.parse(response.body))
          .to eq('message' =>
              'You are not authorized to view the people.')
      end
    end
  end
end
