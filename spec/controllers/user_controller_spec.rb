require 'rails_helper'

RSpec.describe 'JobSeeker', :type => :request do
  before(:all) do
    @url = '/jobseeker/'
  end
  describe "GET #new" do
    it "returns http success" do
      get @url + 'new'
      expect(response).to render_template(:_new)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http success" do
      post @url, {:job_seeker => {:first_name => 'john',
                                :last_name=>'doe',
                                :email => 'john@doe.com',
                                :password => '12345678',
                                :password_confirmation => '12345678'}}
      expect(response).to have_http_status(200)
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
RSpec.describe 'User', :type => :request do
  describe 'GET #activate' do
    subject {FactoryGirl.create(:user)}
    it 'returns http success' do
      get "/user/#{subject.activation_token}/activate/"
      user = User.find_by_email(subject.email)
      expect(response).to redirect_to(root_path)
      expect(user.activated?).to be true
    end
    describe 'Errors' do
      it 'Invalid activation token' do
        get '/user/1234/activate/'
        expect(response).to redirect_to(root_path)
        expect(subject.activated?).to be false
      end
    end
  end
end