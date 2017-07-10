require 'rails_helper'

RSpec.describe RecaptchaService, type: :model do
  context 'User login with captcha' do
    describe 'verify recaptcha response' do
      let!(:captcha_response) { 'XX' }
      let!(:ip_address) { '168.140.181.4' }
      before :each do
        stub_recaptcha_verify
      end
      it 'should login with correct recaptcha' do
        expect(RecaptchaService.verify(captcha_response, ip_address)).to be true
      end
      it 'is disallowed when no recaptcha' do
         expect(RecaptchaService.verify(nil, ip_address)).to be false
      end
    end
  end
end
