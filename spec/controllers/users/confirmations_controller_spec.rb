require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :controller do
	describe "get confirmation_token" do
	  before(:each) do
  	    @request.env["devise.mapping"] = Devise.mappings[:user]
  	  end
      @js = FactoryGirl.create(:user_applicant)
      @js.send_confirmation_instructions
      @user_token = @js.confirmation_token
	  it 'confirms user login' do
        get :show, confirmation_token: @user_token
        expect(response).to render_template(:login_path)
       end
    end
end
