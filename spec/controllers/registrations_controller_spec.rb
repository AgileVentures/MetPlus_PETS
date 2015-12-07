require 'rails_helper'


describe Devise::RegistrationsController, type: :controller do
             
	it "should route 'users/new' correctly" do
		expect(:get => '/users/new').to route_to(controller: "devise/registrations", action: 'new')
	end

end