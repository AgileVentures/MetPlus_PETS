require 'rails_helper'
RSpec.shared_examples 'unauthorized' do
  before :each do
    warden.set_user user
    my_request
  end
  it 'returns http unauthorized' do
    expect(response).to have_http_status(302)
  end
  it 'check content' do
    expect(response).to redirect_to(root_path)
  end
  it 'sets the message' do
    expect(flash[:alert]).to match(/^You are not authorized to/)
  end
end
RSpec.shared_examples 'unauthorized all' do
  let(:agency) { FactoryGirl.create(:agency) }
  let(:company) { FactoryGirl.create(:company) }
  context 'Case Manager' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:case_manager, agency: agency) }
    end
  end
  context 'Job Developer' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:job_developer, agency: agency) }
    end
  end
  context 'Company Admin' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:company_admin, company: company) }
    end
  end
end
RSpec.shared_examples 'unauthorized all non-agency people' do
  let(:agency) { FactoryGirl.create(:agency) }
  let(:company) { FactoryGirl.create(:company) }
  context 'Not logged in' do
    subject { my_request }
    it 'returns http redirect' do
      expect(subject).to have_http_status(302)
    end
    it 'check redirect url' do
      expect(subject).to redirect_to(root_path)
    end
  end
  context 'Job Seeker' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:job_seeker) }
    end
  end
  context 'Company admin' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:company_admin, company: company) }
    end
  end
  context 'Company contact' do
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:company_contact, company: company) }
    end
  end
end
RSpec.describe BranchesController, type: :controller do
  let(:agency)  { FactoryGirl.create(:agency) }
  let(:branch)  { FactoryGirl.create(:branch, agency: agency) }
  let(:jd)      { FactoryGirl.create(:job_developer, agency: agency) }
  let(:cm)      { FactoryGirl.create(:case_manager, agency: agency) }
  let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:company) { FactoryGirl.create(:company) }
  let(:ca)      { FactoryGirl.create(:company_admin, company: company) }
  let(:cc)      { FactoryGirl.create(:company_contact, company: company) }
  let(:js)      { FactoryGirl.create(:job_seeker) }
  describe 'GET #show' do
    before(:each) do
      sign_in admin
      get :show, id: branch.id
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
    let(:branch1)  { FactoryGirl.create(:branch, agency: agency) }
    let(:branch2)  { FactoryGirl.build(:branch, agency: agency, code: branch1.code) }
    context 'valid attributes' do
      before(:each) do
        sign_in admin
        post :create, agency_id: agency, branch: FactoryGirl.attributes_for(:branch)
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
        branch_hash = FactoryGirl.attributes_for(:branch, code: branch1.code)
        branch_hash[:address_attributes] =
          FactoryGirl.attributes_for(:address, zipcode: '123456')
        post :create, agency_id: agency, branch: branch_hash
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
      get :new, agency_id: agency
    end
    it 'assigns @agency for branch creation' do
      expect(assigns(:agency)).to eq agency
    end
    it 'returns http success' do
      get :new, agency_id: agency
      expect(response).to have_http_status(:success)
    end
  end
  describe 'GET #edit' do
    before(:each) do
      sign_in admin
      get :edit, id: branch.id
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
    let(:branch1)  { FactoryGirl.create(:branch, agency: agency) }
    let(:branch2)  { FactoryGirl.create(:branch, agency: agency) }
    context 'valid attributes' do
      before(:each) do
        sign_in admin
        patch :update, branch: FactoryGirl.attributes_for(:branch),
                       id: branch1.id
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
        branch_hash = FactoryGirl.attributes_for(:branch, code: branch1.code)
        branch_hash[:address_attributes] =
          FactoryGirl.attributes_for(:address, zipcode: '123456')

        patch :update, branch: branch_hash, id: branch2.id
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
      delete :destroy, id: branch.id
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
        get :new, agency_id: agency
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all' do
        let(:my_request) { get :new, agency_id: agency }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { get :new, agency_id: agency }
      end
    end
    context '#create' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        post :create, agency_id: agency, branch: FactoryGirl.attributes_for(:branch)
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all' do
        let(:my_request) { get :new, agency_id: agency }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { get :new, agency_id: agency }
      end
    end
    context '#update' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        patch :update, id: branch.id, branch: FactoryGirl.attributes_for(:branch)
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all' do
        let(:my_request) { post :create, agency_id: agency, branch: FactoryGirl.attributes_for(:branch) }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { post :create, agency_id: agency, branch: FactoryGirl.attributes_for(:branch) }
      end
    end
    context '#edit' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :edit, id: branch.id
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all' do
        let(:my_request) { get :edit, id: branch.id }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { get :edit, id: branch.id }
      end
    end
    context '#destroy' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        delete :destroy, id: branch.id
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all' do
        let(:my_request) { delete :destroy, id: branch.id }
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { delete :destroy, id: branch.id }
      end
    end
    context '#show' do
      it 'authorizes agency admin' do
        allow(controller).to receive(:current_user).and_return(admin)
        get :show, id: branch.id
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency person job developer' do
        allow(controller).to receive(:current_user).and_return(jd)
        get :show, id: branch.id
        expect(subject).to_not receive(:user_not_authorized)
      end
      it 'authorizes agency person case manager' do
        allow(controller).to receive(:current_user).and_return(cm)
        get :show, id: branch.id
        expect(subject).to_not receive(:user_not_authorized)
      end
      it_behaves_like 'unauthorized all non-agency people' do
        let(:my_request) { get :show, id: branch.id }
      end
    end
  end
end
