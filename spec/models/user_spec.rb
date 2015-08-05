require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Check model restrictions' do
    subject { FactoryGirl.build(:user) }
    describe 'Email check' do
      it { should validate_uniqueness_of(:email) }
      it { should validate_presence_of(:email) }
      it { should_not allow_value('asd', 'asd@asd', 'asdasdadaosijaosdmaosdinausdnaosndasd')
                          .for(:email) }
    end
    describe 'Password check' do
      subject { FactoryGirl.build(:user, password: '') }
      it {should validate_presence_of(:password) }
      it {should have_secure_password }
    end
  end
  describe 'Activation token' do
    describe 'Should be created automatically' do
      subject {FactoryGirl.create(:user)}
      it {expect(subject.activation_token).not_to eq nil}
    end
  end
end
