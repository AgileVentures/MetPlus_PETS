require 'rails_helper'

RSpec.describe CompanyRegistrationsController, type: :controller do

  describe "GET #show" do
    let(:company_person)  { FactoryGirl.create(:company_person) }
    let!(:company) do
      $comp = FactoryGirl.build(:company)
      $comp.company_people << company_person
      $comp.save
      $comp
    end

    before(:each) do
      get :show, id: company
    end
    it 'assigns @company for view' do
      expect(assigns(:company)).to eq company
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    let(:company_person)  { FactoryGirl.create(:company_person) }
    let!(:company) do
      $comp = FactoryGirl.build(:company)
      $comp.company_people << company_person
      $comp.save
      $comp
    end

    before(:each) do
      delete :destroy, id: company
    end
    it 'sets flash message' do
      expect(flash[:notice]).
          to eq "Registration for '#{company.name}' deleted."
    end
    it "returns redirect status" do
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST #create" do

    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user)]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end

    context 'valid attributes' do
      before(:each) do
        post :create, company: registration_params
      end
      it "sets User 'approved' to false" do
        expect(assigns(:company).company_people[0].user.approved).to be false
      end
      it "sets company status to Pending" do
        expect(assigns(:company).status).
                            to eq Company::STATUS[:PND]
      end
      it "sets company person status to Pending" do
        expect(assigns(:company).company_people[0].status).
                            to eq CompanyPerson::STATUS[:PND]
      end
      it 'sets flash message' do
        expect(flash[:notice]).to match "You have successfully registered your company!"
      end
      it 'renders confirmation view' do
        expect(response).to render_template(:confirmation)
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    it 'sends registration-pending email' do
      expect { post :create, company: registration_params }.
                    to change(all_emails, :count).by(+1)
    end

    context 'invalid attributes' do
      before(:each) do
        registration_params[:name] = nil
        registration_params[:phone] = '222-333-12345'
        post :create, company: registration_params
      end
      it 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).
            to match_array ["Name can't be blank", "Phone incorrect format"]
      end
      it 'renders new template' do
        expect(response).to render_template('new')
      end
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #approve" do
    let!(:agency)   { FactoryGirl.create(:agency) }

    let!(:registration_params) do
      $params = FactoryGirl.attributes_for(:company)
      $params[:company_people_attributes] =
                [FactoryGirl.attributes_for(:user)]
      $params[:addresses_attributes] =
                [FactoryGirl.attributes_for(:address)]
      $params
    end
    before(:each) do
      post :create, company: registration_params
    end

    it 'sends registration-approved and account-confirm emails' do
      expect { post :approve,
          id: Company.find_by_name(registration_params[:name]) }.
                    to change(all_emails, :count).by(+2)
    end
    context 'after approval' do
      before(:each) do
        post :approve, id: Company.find_by_name(registration_params[:name])
      end
      it 'sets flash message' do
        expect(flash[:notice]).to eq "Company contact has been notified of registration approval."
      end
      it "returns redirect status" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

end
