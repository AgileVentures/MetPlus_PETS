require 'rails_helper'

RSpec.shared_examples 'unauthorizes all' do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }

  context 'Case Manager' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:case_manager, agency: agency) }
    end
  end

  context 'Job Developer' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:job_developer, agency: agency) }
    end
  end

  context 'Company Admin' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:company_admin, company: company) }
    end
  end
end

RSpec.shared_examples 'unauthorized all non-agency people' do
  let(:agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company) }

  context 'Not logged in' do
    it_behaves_like 'unauthenticated request'
  end

  context 'Job Seeker' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:job_seeker) }
    end
  end

  context 'Company admin' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:company_admin, company: company) }
    end
  end

  context 'Company contact' do
    it_behaves_like 'unauthorized request' do
      let(:user) { FactoryBot.create(:company_contact, company: company) }
    end
  end
end

RSpec.describe BranchesController, type: :controller do
  let(:agency)  { FactoryBot.create(:agency) }
  let(:branch)  { FactoryBot.create(:branch, agency: agency) }
  let(:jd)      { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm)      { FactoryBot.create(:case_manager, agency: agency) }
  let(:admin)   { FactoryBot.create(:agency_admin, agency: agency) }
  let(:company) { FactoryBot.create(:company) }
  let(:ca)      { FactoryBot.create(:company_admin, company: company) }
  let(:cc)      { FactoryBot.create(:company_contact, company: company) }
  let(:js)      { FactoryBot.create(:job_seeker) }
  describe 'GET #show' do
    before(:each) do
      sign_in admin
      get :show, params: { id: branch.id }
    end
    it 'assigns @branch for view' do
      expect(assigns(:branch)).to eq branch
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
  describe 'POST #create' do
    let(:branch1)  { FactoryBot.create(:branch, agency: agency) }
    let(:branch2)  do
      FactoryBot.build(:branch, agency: agency, code: branch1.code)
    end
    context 'valid attributes' do
      before(:each) do
        sign_in admin
        post :create, params: { agency_id: agency,
                                branch: FactoryBot.attributes_for(:branch) }
      end
      it 'assigns @agency for branch association' do
        expect(assigns(:agency)).to eq agency
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Branch was successfully created.'
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to agency_admin home' do
        expect(response).to redirect_to(agency_admin_home_path)
      end
    end
    context 'invalid attributes' do
      render_views
      before(:each) do
        sign_in admin
        branch2.address.assign_attributes(zipcode: '123456')
        branch2.valid?
        branch_hash = FactoryBot.attributes_for(:branch, code: branch1.code)
        branch_hash[:address_attributes] =
          FactoryBot.attributes_for(:address, zipcode: '123456')
        post :create, params: { agency_id: agency, branch: branch_hash }
      end
      it 'assigns @agency for branch association' do
        expect(assigns(:agency)).to eq agency
      end
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it 'renders partial for errors' do
        expect(response).to render_template(partial: 'shared/_error_messages')
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
  describe 'GET #new' do
    before(:each) do
      sign_in admin
      get :new, params: { agency_id: agency }
    end
    it 'assigns @agency for branch creation' do
      expect(assigns(:agency)).to eq agency
    end
    it 'returns http success' do
      get :new, params: { agency_id: agency }
      expect(response).to have_http_status(:success)
    end
  end
  describe 'GET #edit' do
    before(:each) do
      sign_in admin
      get :edit, params: { id: branch.id }
    end
    it 'assigns @branch for form' do
      expect(assigns(:branch)).to eq branch
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
  describe 'PATCH #update' do
    let(:branch1)  { FactoryBot.create(:branch, agency: agency) }
    let(:branch2)  { FactoryBot.create(:branch, agency: agency) }
    context 'valid attributes' do
      before(:each) do
        sign_in admin
        patch :update, params: { branch: FactoryBot.attributes_for(:branch),
                                 id: branch1.id }
      end
      it 'assigns @branch for updating' do
        expect(assigns(:branch)).to eq branch1
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Branch was successfully updated.'
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to branch #show view' do
        expect(response).to redirect_to(branch_path(branch1))
      end
    end
    context 'invalid attributes' do
      render_views
      before(:each) do
        sign_in admin
        branch2.assign_attributes(code: branch1.code)
        branch2.address.assign_attributes(zipcode: '123456')
        branch2.valid?
        branch_hash = FactoryBot.attributes_for(:branch, code: branch1.code)
        branch_hash[:address_attributes] =
          FactoryBot.attributes_for(:address, zipcode: '123456')

        patch :update, params: { branch: branch_hash, id: branch2.id }
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
  describe 'DELETE #destroy' do
    before(:each) do
      sign_in admin
      delete :destroy, params: { id: branch.id }
    end
    it 'sets flash message' do
      expect(flash[:notice]).to eq "Branch '#{branch.code}' deleted."
    end
    it 'returns redirect status' do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'action authorization' do
    context '#new' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :new, params: { agency_id: agency }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorizes all' do
        let(:request) { get :new, params: { agency_id: agency } }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:request) { get :new, params: { agency_id: agency } }
      end
    end
    context '#create' do
      let(:request) { get :new, params: { agency_id: agency } }
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        post :create, params: { agency_id: agency,
                                branch: FactoryBot.attributes_for(:branch) }
        expect(subject).to_not receive(:user_not_authorized)
      end

      it_behaves_like 'unauthorizes all'
      it_behaves_like 'unauthorized all non-agency people'
    end

    context '#update' do
      let(:request) do
        post :create, params: { agency_id: agency,
                                branch: FactoryBot.attributes_for(:branch) }
      end
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        patch :update, params: { id: branch.id,
                                 branch: FactoryBot.attributes_for(:branch) }
        expect(subject).to_not receive(:user_not_authorized)
      end

      it_behaves_like 'unauthorizes all'
      it_behaves_like 'unauthorized all non-agency people'
    end

    context '#edit' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :edit, params: { id: branch.id }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorizes all' do
        let(:request) { get :edit, params: { id: branch.id } }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:request) { get :edit, params: { id: branch.id } }
      end
    end
    context '#destroy' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        delete :destroy, params: { id: branch.id }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorizes all' do
        let(:request) { delete :destroy, params: { id: branch.id } }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:request) { delete :destroy, params: { id: branch.id } }
      end
    end
    context '#show' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :show, params: { id: branch.id }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency person job developer' do
        allow(controller).to receive(:current_user).and_return(jd)
        get :show, params: { id: branch.id }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency person case manager' do
        allow(controller).to receive(:current_user).and_return(cm)
        get :show, params: { id: branch.id }
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:request) { get :show, params: { id: branch.id } }
      end
    end
  end
end
