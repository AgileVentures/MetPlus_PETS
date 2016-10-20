require 'rails_helper'

RSpec.describe EmailValidateService, type: :model do

  describe 'email address is not specified' do
    it 'returns invalid address' do
      result = {status: 'SUCCESS', valid: false, did_you_mean: nil}
      expect(EmailValidateService.validate_email('')).to eq result
      expect(RestClient).to_not receive(:get)
    end
  end

  describe 'email address is valid' do
    it 'returns valid address' do
      result = {status: 'SUCCESS', valid: true, did_you_mean: nil}

      expect(EmailValidateService.validate_email('goodone@gmail.com')).to eq result
    end
  end

  describe 'email address is NOT valid' do
    it 'returns invalid address' do

      stub_email_validate_invalid
      result = {status: 'SUCCESS', valid: false, did_you_mean: 'myaddress@gmail.com'}

      expect(EmailValidateService.validate_email('myaddress@gmal.com')).to eq result
    end
  end

  describe 'validate service NOT available' do
    it 'returns ERROR status' do
      stub_email_validate_error
      result = {status: 'ERROR'}

      expect(EmailValidateService.validate_email('myemail@gmail.com')).to eq result
    end
  end


end
