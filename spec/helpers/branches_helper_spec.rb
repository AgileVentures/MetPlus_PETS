require 'rails_helper'

RSpec.describe BranchesHelper, type: :helper do
  context 'single_line_address method' do
    it 'returns string for address' do
      address = FactoryGirl.build(:address)
      expect(single_line_address(address)).
          to eq "#{address.street}, #{address.city}, #{address.zipcode}"
    end
    it 'return no-address for nil' do
      expect(single_line_address(nil)).
          to eq 'No Address'
    end
  end
end