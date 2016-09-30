require 'rails_helper'

RSpec.describe BranchesController, type: :controller do

  describe "GET #show" do
    let(:branch)   { FactoryGirl.create(:branch, agency: agency) }
    let(:agency)  {FactoryGirl.create(:agency)}
    let(:jd)      {FactoryGirl.create(:job_developer, agency: agency)}
    let(:cm)      {FactoryGirl.create(:case_manager, agency: agency)}
    let(:admin)   {FactoryGirl.create(:agency_admin, agency: agency)}

    before(:each) do
      sign_in admin
      get :show, id: branch.id
    end
    
    before(:each) do
      sign_in jd
      get :show, id: branch.id
    end
 
    before(:each) do
      sign_in cm
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

    let(:agency)  { FactoryGirl.create(:agency) }
    let(:admin)   {FactoryGirl.create(:agency_admin, agency: agency)}
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

    let(:agency)        { FactoryGirl.create(:agency) }
    let(:admin)         { FactoryGirl.create(:agency_admin, agency: agency) }
    
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
    
    let(:agency)  { FactoryGirl.create(:agency) }
    let(:admin)   { FactoryGirl.create(:agency_admin, agency: agency)}
    let(:branch)  { FactoryGirl.create(:branch, agency: agency) }
    

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

    let(:agency)   { FactoryGirl.create(:agency) }
    let(:admin)   {FactoryGirl.create(:agency_admin, agency: agency)}
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
    
    let(:agency)   { FactoryGirl.create(:agency) }
    let(:branch)  { FactoryGirl.create(:branch, agency: agency) }
    let(:admin)   {FactoryGirl.create(:agency_admin, agency: agency)}

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
end

