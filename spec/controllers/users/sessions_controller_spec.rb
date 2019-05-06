require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  let(:user) { FactoryBot.create(:job_seeker) }
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  describe 'POST #create /users/sessions without remember me' do
    it 'logs in without remember me' do
      post :create, params: {
        user: { email: user.email, password: user.password,
                person_type: user.actable_type }
      }
      expect(cookies[:user_id]).to eq user.id
      expect(cookies[:person_type]).to eq user.actable_type
    end
  end
  describe 'POST #create /users/sessions with remember me' do
    it 'sets cookies to expire in 1 year' do
      # stub out the #cookies method
      stub_cookie_jar = HashWithIndifferentAccess.new
      allow(controller).to receive(:cookies).and_return(stub_cookie_jar)
      post :create, params: {
        user: { email: user.email, password: user.password,
                remember_me: '1',
                person_type: user.actable_type }
      }
      user_id_cookie = stub_cookie_jar[:user_id]
      expect(user_id_cookie[:value]).to eq user.id
      expect(user_id_cookie[:expires])
        .to be_within(5.seconds).of 1.year.from_now
      person_type_cookie = stub_cookie_jar[:person_type]
      expect(person_type_cookie[:value]).to eq user.actable_type
      expect(person_type_cookie[:expires])
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
      expect(get: 'logout').to route_to(controller: 'users/sessions',
                                           action: 'destroy')
    end
  end
end
