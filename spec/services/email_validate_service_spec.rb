require 'rails_helper'
include ServiceStubHelpers::EmailValidator

RSpec.describe EmailValidateService, type: :model do

  describe 'email address is not specified' do
    it 'returns invalid address' do
      result = {status: 'SUCCESS', valid: false, did_you_mean: nil}
      expect(EmailValidateService.validate_email('')).to eq result
    end
  end

  describe 'email address is valid' do
    it 'returns valid address' do

      stub_email_validate_valid('goodone@gmail.com')
      result = {status: 'SUCCESS', valid: true, did_you_mean: nil}

      expect(EmailValidateService.validate_email('goodone@gmail.com')).to eq result
    end
  end

  describe 'email address is NOT valid' do
    it 'returns invalid address' do

      stub_email_validate_invalid('badone@gmal.com')
      result = {status: 'SUCCESS', valid: false, did_you_mean: 'badone@gmail.com'}

      expect(EmailValidateService.validate_email('badone@gmal.com')).to eq result
    end
  end

  describe 'validate service NOT available' do
    it 'returns ERROR status' do
      stub_email_validate_error('myemail@gmail.com')
      result = {status: 'ERROR'}

      expect(EmailValidateService.validate_email('myemail@gmail.com')).to eq result
    end
  end


end
