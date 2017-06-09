require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe 'POST #create /users/sessions' do
    let(:user) { FactoryGirl.create(:job_seeker) }

    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it 'logs in without remember me' do
      post :create,
           user: { email: user.email, password: user.password,
                   person_type: user.actable_type }
      expect(cookies[:user_id]).to eq user.id
      expect(cookies[:person_type]).to eq user.actable_type
    end
    it 'logs in with remember me' do
      # stubs out the #cookies method
      stub_cookie_jar = HashWithIndifferentAccess.new
      controller.stub(:cookies) { stub_cookie_jar }
      post :create,
           user: { email: user.email, password: user.password,
                   remember_me: '1',
                   person_type: user.actable_type }
      expect(cookies[:user_id]).to eq user.id
      expect(cookies[:person_type]).to eq user.actable_type
      expiring_user_id_cookie = stub_cookie_jar[:user_id]
      expect(expiring_user_id_cookie[:expires])
        .to be_within(5.seconds).of 1.year.from_now
      expiring_person_type_cookie = stub_cookie_jar[:person_type]
      expect(expiring_person_type_cookie[:expires])
        .to be_within(5.seconds).of 1.year.from_now
    end
  end
  describe 'user logs in' do
    it "should route '/login' correctly" do
      expect(get: 'login').to route_to(controller: 'users/sessions',
                                       action: 'new')
    end
  end
  describe 'user logs out' do
    it "should route '/logout' correctly" do
      expect(delete: 'logout').to route_to(controller: 'users/sessions',
                                           action: 'destroy')
    end
  end
end
