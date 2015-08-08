require 'rails_helper'
RSpec.describe Employer, type: :model do
  describe 'Check model restrictions' do
    subject { FactoryGirl.build(:employer) }
    describe 'Phone check' do
      it { should_not allow_value('asd', '123456', '123 123 12345', '123 1231 1234', '1123 123 1234', ' 123 123 1234')
                          .for(:phone)}
      it { should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234', '1231231234', '+1 (123) 1231234')
                      .for(:phone)}
    end
    describe 'Email check' do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email) }
      it { should_not allow_value('asd', 'asd@asd', 'asdasdadaosijaosdmaosdinausdnaosndasd')
                          .for(:email) }
    end
    describe 'Password check' do
      subject { FactoryGirl.build(:employer, password: '') }
      it {should validate_presence_of(:password) }
      it {should have_secure_password }
      it {should validate_confirmation_of(:password)}
    end
    describe 'Company check' do
      it {should validate_presence_of(:company) }
      it {should belong_to(:company) }
    end
  end
end
