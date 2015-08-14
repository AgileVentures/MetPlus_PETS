require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  let(:user1) {FactoryGirl.create(:user, :email => 'user@bam.com', :password => 'my password')}
  let(:user2) {
    user1 = FactoryGirl.create(:user, :email => 'user1@bam.com', :password => 'my password')
    user1.activate(user1.activation_token)
    user1
  }
  describe "POST #create" do
    describe 'json' do
      it 'success' do
        user1
        user2
        post :create, format: :json, user: {email: 'user1@bam.com', password: 'my password'}
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({:url => root_path}.to_json)
      end
      it 'inexistant user' do
        user1
        user2
        post :create,  user: {email: 'user2@bam.com', password: 'my password'}, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({:errors => 'Unable to find user'}.to_json)
      end
      it 'user not activated' do
        user1
        user2
        post :create,  user: {email: 'user@bam.com', password: 'my password'}, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({:errors => 'User is not activated'}.to_json)
      end
      it 'wrong password' do
        user1
        user2
        post :create,  user: {email: 'user1@bam.com', password: 'my password1'}, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({:errors => 'Email and password do not match'}.to_json)
      end
    end
    describe 'html' do
      it 'success' do
        user1
        user2
        post :create, format: :html,  user: {email: 'user1@bam.com', password: 'my password'}
        expect(response).to redirect_to(root_path)
      end
      it 'inexistant user' do
        user1
        user2
        post :create,  user: {email: 'user2@bam.com', password: 'my password'}, format: :html
        expect(response).to redirect_to(root_path)
      end
      it 'user not activated' do
        user1
        user2
        post :create,  user: {email: 'user@bam.com', password: 'my password'}, format: :html
        expect(response).to redirect_to(root_path)
      end
      it 'wrong password' do
        user1
        user2
        post :create,  user: {email: 'user1@bam.com', password: 'my password1'}, format: :html
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #destroy" do
    it "returns http success" do
      get :destroy
      expect(response).to redirect_to(root_path)
    end
  end

end
