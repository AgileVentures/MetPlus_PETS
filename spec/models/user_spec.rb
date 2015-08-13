require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Check model restrictions' do
    describe 'Email check' do
      subject {FactoryGirl.build(:user)}
      it { should validate_uniqueness_of(:email) }
      it { should validate_presence_of(:email) }
      it { should_not allow_value('asd', 'asd@asd', 'asdasdadaosijaosdmaosdinausdnaosndasd')
                          .for(:email) }
    end
    describe 'Password check' do
      subject { FactoryGirl.build(:user, password: '') }
      it {should validate_presence_of(:password) }
      it {should have_secure_password }
      it {should validate_confirmation_of(:password)}
    end
  end
  describe 'Activation token' do
    after(:all) {
      DatabaseCleaner.clean_with(:truncation)
    }
    describe 'Should be created automatically' do
      subject {FactoryGirl.create(:user)}
      it {expect(subject.activation_token).not_to eq nil}
    end
  end
  describe '#login!' do
    let (:user_activated) {
      user = FactoryGirl.create(:user, :email => 'bamm1@place.com', :password => 'new password')
      user.activate(user.activation_token)
      user
    }
    let (:user_not_activated) {
      FactoryGirl.create(:user, :email => 'bamm@place.com', :password => 'new password')
    }
    describe 'activated' do
      it 'success' do
        user_activated
        expect(User.login!('bamm1@place.com', 'new password')).to eql user_activated
      end
      it 'invalid password' do
        user_activated
        expect {
          User.login!('bamm1@place.com', 'new password1')
        }.to raise_error(Exceptions::User::UnableToAuthenticate)
      end
      it {

        expect {
          User.login!('bamm1@place.com1', 'new password')
        }.to raise_error(Exceptions::User::UserNotFound)
      }
    end
    describe 'not activated' do
      it {expect {
        User.login!(user_not_activated.email, 'new password1')
        }.to raise_error(Exceptions::User::NotActivated)}
    end
  end
  describe '#activate' do
    let (:user) {
      user = FactoryGirl.create(:user, :email => 'bamm1@place.com', :password => 'new password')
      user
    }
    it 'success' do
      expect(user.activate(user.activation_token)).to eql true
      expect(user.activated?).to eql true
    end
    it 'invalid token' do
      expect(user.activate('123')).to eql false
      expect(user.activated?).to eql false
    end
  end
  describe '#find_by_activation_token' do
    before (:all) {
      @user = FactoryGirl.create(:user, :email => 'bamm1@place.com', :password => 'new password')
      @user1 = FactoryGirl.create(:user, :email => 'bamm@place.com', :password => 'new password')
    }
    it 'success' do
      expect(User.find_by_activation_token(@user.activation_token)).to eql @user
    end
    it 'found none after activation' do
      expect(User.find_by_activation_token(@user.activation_token)).to eql @user
      token = @user.activation_token
      @user.activate(token)
      expect(User.find_by_activation_token(token)).to eql nil
    end
    it 'invalid token' do
      expect(User.find_by_activation_token('1234')).to eql nil
    end
  end
end
