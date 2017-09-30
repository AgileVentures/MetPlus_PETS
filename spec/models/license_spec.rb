require 'rails_helper'

RSpec.describe License, type: :model do
  let(:license) { FactoryGirl.build(:license) }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(license).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:job_licenses).dependent(:destroy) }
    it { is_expected.to have_many(:jobs).through(:job_licenses) }
  end

  describe '#license_description' do
    it 'returns abbreviation and title' do
      expect(license.license_description).
        to match /^#{Regexp.quote(license.abbr)}.*#{Regexp.quote(license.title)}/
    end
  end
end
