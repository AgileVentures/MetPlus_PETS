require 'rails_helper'
include CompanyPeopleViewer

RSpec.describe CompanyPeopleController, type: :controller do
  describe "GET #edit_profile" do
    before(:each) do
      @companyperson = FactoryGirl.create(:company_person)
      get :edit_profile, id: @companyperson
    end

    it "renders edit_profile template" do
      expect(response).to render_template 'edit_profile'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #home" do
    before(:each) do
      @companyperson = FactoryGirl.create(:company_person)
      sign_in @companyperson
      get :home, id: @companyperson
    end

    it 'instance vars for view' do
      expect(assigns(:company)).to eq @companyperson.company
      expect(assigns(:task_type)).to eq 'mine-open'
      expect(assigns(:job_type)).to eq 'my-company-all'
      expect(assigns(:people_type)).to eq 'my-company-all'

    end
    it "renders edit_profile template" do
      expect(response).to render_template 'home'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update_profile" do

    context "valid attributes" do
      before(:each) do
        @companyperson = FactoryGirl.build(:company_person)
        @companyperson.company_roles <<
            FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])
        @companyperson.save
        patch :update_profile, id: @companyperson, company_person: FactoryGirl.attributes_for(:user)

      end

      it 'sets flash message' do
         expect(flash[:notice]).to eq "Your profile was updated successfully."
      end
      it 'returns redirect status' do
         expect(response).to have_http_status(:redirect)
      end
      it 'redirects to mainpage' do
         expect(response).to redirect_to(root_path)
      end
    end
    context "valid attributes without password change" do
       before(:each) do
         @companyperson =  FactoryGirl.create(:company_admin,
                                              :password => 'testing.....',
                                              :password_confirmation => 'testing.....')
         @password = @companyperson.encrypted_password
         patch :update_profile, company_person:FactoryGirl.attributes_for(:company_person,
                                                                          first_name:'John',
                                                                          last_name:'Smith',
                                                                          phone:'780-890-8976',
                                                                          title: 'Line Manager',
                                                                          password: '',
                                                                          password_confirmation: ''),
               id:@companyperson
         @companyperson.reload
       end
       it 'sets a title' do
         expect(@companyperson.title).to eq ("Line Manager")
       end
       it 'sets a firstname' do
         expect(@companyperson.first_name).to eq ("John")
       end
       it 'sets a lastname' do
         expect(@companyperson.last_name).to eq ("Smith")
       end
       it 'dont change password' do
         expect(@companyperson.encrypted_password).to eq (@password)
       end
       it 'sets flash message' do
         expect(flash[:notice]).to eq "Your profile was updated successfully."
       end
       it 'returns redirect status' do
         expect(response).to have_http_status(:redirect)
       end
       it 'redirects to mainpage' do
         expect(response).to redirect_to(root_path)
       end
     end
  end

  describe 'GET #list_people' do
    let(:company) { FactoryGirl.create(:company) }

    let!(:cp1) { FactoryGirl.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp3) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp4) { FactoryGirl.create(:company_contact, company: company) }

    before(:each) do
      sign_in cp1
      xhr :get, :list_people, company_id: company.id,
                people_type: 'my-company-all'
    end
    it 'assigns @people to collection of all company people' do
      expect(assigns(:people)).to include cp1, cp2, cp3, cp4
    end
    it 'renders company_people/list_people template' do
      expect(response).to render_template('company_people/_list_people')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end
