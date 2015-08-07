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

  describe "Create user action" do
    it "returns http success" do
      post @url, {:job_seeker => {:first_name => 'john',
                                :last_name=>'doe',
                                :email => 'john@doe.com',
                                :password => '12345678',
                                :password_confirmation => '12345678'}}
      expect(response).to redirect_to(root_path)
    end
    describe 'Errors' do
      describe 'Missing parameters' do
        it 'Missing parameters redirection' do
          post @url, {:jobseeker => {:first_name => 'name'}}, {'HTTP_REFERER' => @url}
          expect(response).to redirect_to(@url)
          expect(response).to have_http_status(302)
        end
      end
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
