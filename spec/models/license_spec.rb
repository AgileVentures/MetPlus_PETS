require 'rails_helper'

RSpec.describe License, type: :model do
  let(:license) { FactoryGirl.build(:license) }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(license).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :abbr }
    it { is_expected.to have_db_column :title }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:job_licenses) }
    it { is_expected.to have_many(:jobs).through(:job_licenses).dependent(:destroy) }
  end

  describe 'Abbr' do
    it { is_expected.to validate_presence_of(:abbr) }
    it 'validates uniqueness of abbreviation' do
      license.save
      license2 = FactoryGirl.build(:license, abbr: license.abbr.downcase)
      expect(license2).to_not be_valid
      expect(license2.errors.full_messages).to include 'Abbr has already been taken'
    end
  end
  describe 'Title' do
    it { is_expected.to validate_presence_of :title }
  end

  describe '#license_description' do
    it 'returns abbreviation and title' do
      expect(license.license_description).
        to match /^#{Regexp.quote(license.abbr)}.*#{Regexp.quote(license.title)}/
    end
  end
end
