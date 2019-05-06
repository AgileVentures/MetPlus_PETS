require 'rails_helper'
include ServiceStubHelpers::EmailValidator

RSpec.describe Users::ConfirmationsController, type: :controller do
  describe 'get confirmation_token' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      allow(Pusher).to receive(:trigger)
      stub_email_validate_valid
    end

    let!(:agency) { FactoryBot.create(:agency) }
    let!(:aa_person) { FactoryBot.create(:agency_admin, agency: agency) }
    let!(:cm_person) { FactoryBot.create(:case_manager, agency: agency) }
    let!(:jd_person) { FactoryBot.create(:job_developer, agency: agency) }

    it 'rejects invalid tag' do
      get :show, params: { confirmation_token: 'HzDZWwMxswSAs_aQSYwd' }
      expect(response).to render_template('users/confirmations/new')
    end
    it 'confirms user email address' do
      @js = FactoryBot.create(:job_seeker_applicant)
      get :show, params: { confirmation_token: @js.confirmation_token }
      expect(flash[:notice]).to eq 'Your email address has been successfully confirmed.'
    end
    it 'allows re-confirmation of user email address' do
      @js = FactoryBot.create(:job_seeker_applicant)
      @user_token = @js.confirmation_token
      get :show, params: { confirmation_token: @js.confirmation_token }
      get :show, params: { confirmation_token: @user_token }
      expect(flash[:notice]).to eq 'Your email address has been successfully confirmed.'
    end
  end
end
