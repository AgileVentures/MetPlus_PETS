require 'rails_helper'

RSpec.describe AddressesHelper, type: :helper do
  let(:address_with_data) { FactoryGirl.create(:address) }
  let(:address_no_data)   { Address.new }

  context '#address_has_data?' do
    it 'returns true if address has data' do
      expect(address_has_data?(address_with_data)).to be true
    end

    it 'returns false if address has no data' do
      expect(address_has_data?(address_no_data)).to be false
    end
  end
end
