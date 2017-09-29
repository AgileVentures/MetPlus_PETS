require 'rails_helper'

RSpec.describe License, type: :model do

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:license)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many(:jobs) }
  end
end
