require 'rails_helper'

RSpec.describe BranchesController, type: :controller do

  describe "GET #create" do
    before(:each) do
      @agency = FactoryGirl.create(:agency)
    end
    it "returns redirect status" do
      get :create, agency_id: @agency
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #new" do
    before(:each) do
      @agency = FactoryGirl.create(:agency)
    end
    it "returns http success" do
      get :new, agency_id: @agency
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    before(:each) do
      @branch = FactoryGirl.create(:branch)
    end
    it "returns http success" do
      get :edit, id: @branch
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #update" do
    before(:each) do
      @branch = FactoryGirl.create(:branch)
    end
    it "returns redirect status" do
      get :update, id: @branch
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #destroy" do
    before(:each) do
      @branch = FactoryGirl.create(:branch)
    end
    it "returns redirect status" do
      get :destroy, id: @branch
      expect(response).to have_http_status(:redirect)
    end
  end

end
