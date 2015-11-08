require 'rails_helper'

RSpec.describe Devise::SessionsController, type: :controller do
	it "should route '/login' correctly" do
		expect(:get => 'login').to route_to(controller: "devise/sessions", action: 'new')
	end

	it "should route '/logout' correctly" do
		expect(:delete => 'logout').to route_to(controller: "devise/sessions", action: 'destroy')
	end

end