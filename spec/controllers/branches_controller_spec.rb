require 'rails_helper'

RSpec.describe BranchesController, type: :controller do
  let(:agency)  {FactoryGirl.create(:agency)}
  let(:branch)   { FactoryGirl.create(:branch, agency: agency) }
  let(:jd)      {FactoryGirl.create(:job_developer, agency: agency)}
  let(:cm)      {FactoryGirl.create(:case_manager, agency: agency)}
  let(:admin)   {FactoryGirl.create(:agency_admin, agency: agency)}
  let(:js)       { FactoryGirl.create(:job_seeker) }


  describe "GET #show" do
    
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
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do

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
        expect(flash[:notice]).to eq "Branch was successfully created."
      end
      it "returns redirect status" do
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
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #new" do

    before(:each) do
      sign_in admin
      get :new, agency_id: agency
    end
    it 'assigns @agency for branch creation' do
      expect(assigns(:agency)).to eq agency
    end
    it "returns http success" do
      get :new , agency_id: agency
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    
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
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do

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
        expect(flash[:notice]).to eq "Branch was successfully updated."
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
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

  end

  describe "DELETE #destroy" do
    
    before(:each) do
      sign_in admin
      delete :destroy, id: branch.id
    end
    it 'sets flash message' do
      expect(flash[:notice]).to eq "Branch '#{branch.code}' deleted."
    end
    it "returns redirect status" do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'action authorization' do
    context '#new' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(admin)
        get :new, agency_id: agency
      end
      it 'does not authorize non-admin agency person' do
        allow(controller).to receive(:current_user).and_return(jd)
        get :new, agency_id: agency
        expect(flash[:alert]).to eq "You are not authorized to create a branch."
      end
    end
  
    context '#create' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(admin)
        post :create, agency_id: agency, branch: FactoryGirl.attributes_for(:branch)
      end
      it 'does not authorize non-admin agency person' do
        allow(controller).to receive(:current_user).and_return(jd)
        post :create, agency_id: agency
        expect(flash[:alert]).to eq "You are not authorized to create a branch."
      end
    end

    context '#update' do
      
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(admin)
        patch :update, id: branch.id, branch: FactoryGirl.attributes_for(:branch)
      end
      it 'does not authorize non-agency admin' do
        allow(controller).to receive(:current_user).and_return(jd)
        patch :update, id: branch.id
        expect(flash[:alert]).
          to eq "You are not authorized to update the branch."
      end
    end

    context '#edit' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(admin)
        get :edit, id: branch.id
      end
      it 'does not authorize non-agency admin' do
        allow(controller).to receive(:current_user).and_return(jd)
        get :edit, id: branch.id
        expect(flash[:alert]).
          to eq "You are not authorized to edit the branch."
      end
    end

    context '#destroy' do
      it 'authorizes agency admin' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(admin)
        delete :destroy, id: branch.id
      end
      it 'does not authorize non-admin agency person' do
        allow(controller).to receive(:current_user).and_return(jd)
        delete :destroy, id: branch.id
        expect(flash[:alert]).
          to eq "You are not authorized to destroy the branch."
      end
    end
    
    context '#show' do
      it 'authorizes agency person' do
        expect(subject).to_not receive(:user_not_authorized)
        allow(controller).to receive(:current_user).and_return(jd)
        get :show, id: branch.id
      end
      it 'does not authorize non-agency person' do
        allow(controller).to receive(:current_user).and_return(js)
        get :show, id: branch.id
        expect(flash[:alert]).
          to eq "You are not authorized to show the branch with id."
      end
    end

  end
  
end

