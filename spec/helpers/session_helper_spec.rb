require 'rails_helper'

RSpec.describe SessionHelper, type: :helper do
  let(:user) {FactoryGirl.create(:user)}
  describe '#current_user' do
    it {expect(current_user).to be nil}
    it {
      session[:user_id] = user.id
      expect(current_user).to eq user
    }
  end
  describe '#logged_in?' do
    it {expect(logged_in?).to be false}
    it {
      session[:user_id] = user.id
      expect(logged_in?).to eq true
    }
  end
end
