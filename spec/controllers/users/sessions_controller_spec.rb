require 'rails_helper'

describe Devise::SessionsController, type: :controller do
  describe 'user logs in with cookies' do
    it "logs in using cookies" do
      js = FactoryGirl.create(:job_seeker)
      @request.cookies[:user_id]     = js.id
      @request.cookies[:person_type] = js.actable_type
      expect(:get => 'login').to route_to(controller: "users/sessions", action: 'new')
    end
  end
  describe 'user logs in' do
	  it "should route '/login' correctly" do
		  expect(:get => 'login').to route_to(controller: "users/sessions", action: 'new')
	  end
  end
  describe 'user logs out' do
	  it "should route '/logout' correctly" do
		  expect(:delete => 'logout').to route_to(controller: "users/sessions", action: 'destroy')
	  end
  end
end
