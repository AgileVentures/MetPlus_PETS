require 'rails_helper'

RSpec.describe JobSeeker, type: :model do
  describe 'Check model restrictions' do
    subject { FactoryGirl.build(:job_seeker) }
    describe 'Email check' do
      it { should validate_uniqueness_of(:email) }
      it { should validate_presence_of(:email) }
      it { should_not allow_value('asd', 'asd@asd', 'asdasdadaosijaosdmaosdinausdnaosndasd')
                          .for(:email) }
    end
    describe 'Password check' do
      subject { FactoryGirl.build(:job_seeker, password: '') }
      it {should validate_presence_of(:password) }
      it {should have_secure_password }
    end
  end
end
