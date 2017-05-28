require 'rails_helper'

describe Devise::SessionsController, type: :controller do
  describe 'user logs in with cookies' do
    before_action :user_logged!
    include UserParameters
    cookies[:user_id]     = current_user.id
    cookies[:person_type] = current_user.actable_type
    expect(:get => 'login').to route_to(controller: "users/sessions", action: 'new')
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
