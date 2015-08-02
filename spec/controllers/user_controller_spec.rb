require 'rails_helper'

RSpec.describe 'JobSeeker', :type => :request do
  before(:all) do
    @url = '/jobseeker/'
  end
  describe "GET #new" do
    it "returns http success" do
      get @url + 'new'
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:success)
    end
  end


  describe "POST #create" do
    it "returns http success" do
      post @url + 'create', :widget => {:name => "My Widget"}
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET #edit" do
    it "returns http success" do
      get @url + 'edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get @url + 'show'
      expect(response).to have_http_status(:success)
    end
  end

end
