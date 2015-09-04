require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe 'Check layout' do
    let(:user){FactoryGirl.build(:user, :email => 'me@place.com', :activation_token => '12345')}
    subject {UserMailer.activation(user)}
    it {should have_subject(/Welcome to MetPlus/)}
    it {should deliver_to('me@place.com')}
    it {should deliver_from('no-reply@metplus.org')}
    it {should have_body_text(/<a href=".+\/user\/#{user.activation_token}\/activate"/)}
  end
end
