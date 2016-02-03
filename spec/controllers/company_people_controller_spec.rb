require 'rails_helper'

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
         @companyperson =  FactoryGirl.build(:company_person)
         @user =  FactoryGirl.create(:user)
         @companyperson.company_roles <<
             FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])
         @companyperson.save
         @companyperson.valid?
         patch :update_profile, company_person:FactoryGirl.attributes_for(:company_person, title: 'Line Manager', password: nil, password_confirmation: nil).merge(FactoryGirl.attributes_for(:user, first_name:'John',last_name:'Smith',phone:'780-890-8976')),id:@companyperson
         @companyperson.reload
         @user.reload

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
end
