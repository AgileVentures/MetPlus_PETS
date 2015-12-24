require 'rails_helper'

RSpec.describe JobSeekersController, type: :controller do

  describe "GET #new" do
    
    it "renders new template" do
      get :new
      expect(response).to render_template 'new'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
 

  describe "GET #edit" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      get :edit, id: @jobseeker
    end
    
    it "renders edit template" do
      expect(response).to render_template 'edit'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response.body).to render_template 'index'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    
  end

  describe "GET #show" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      get :show, id: @jobseeker
    end
    it "it renders  the show template" do
      expect(response).to render_template 'show'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end







  
