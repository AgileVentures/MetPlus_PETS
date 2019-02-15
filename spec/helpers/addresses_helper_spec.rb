require 'rails_helper'

RSpec.describe AddressesHelper, type: :helper do
  let(:address_with_data) { FactoryBot.create(:address) }
  let(:address_no_data)   { Address.new }

  context '#address_has_data?' do
    it 'returns true if address has data' do
      expect(address_has_data?(address_with_data)).to be true
    end

    it 'returns false if address has no data' do
      expect(address_has_data?(address_no_data)).to be false
    end
  end

  context '#address_subform_visibility' do
    it 'returns nil if address has data' do
      expect(address_subform_visibility(address_with_data)).to be_nil
    end

    it 'returns no-display style if address has no data' do
      expect(address_subform_visibility(address_no_data)).to eq 'hidden'
    end
  end

  context '#address_subform_toggle_text' do
    it 'returns cancel text if address has data' do
      expect(address_subform_toggle_text(address_with_data))
        .to eq 'Cancel new location'
    end

    it 'returns create text if address has data' do
      expect(address_subform_toggle_text(address_no_data))
        .to eq 'Create new location'
    end
  end
end
