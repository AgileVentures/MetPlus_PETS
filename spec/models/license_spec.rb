require 'rails_helper'

RSpec.describe License, type: :model do
  let(:license) { FactoryBot.build(:license) }

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

  describe 'When a license is destroyed' do
    let(:license) 		{ FactoryBot.create(:license) }
    let(:job) 				{ FactoryBot.create(:job) }
    let(:job_license) { FactoryBot.create(:job_license, job: job, license: license)}
    it 'jobs :through association with dependent::destroy deletes record' do
      expect(job_license).to be_valid
      job_lcsn_id = license.job_licenses.first.id
      license.destroy
      expect{JobLicense.find(job_lcsn_id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'Abbr' do
    it { is_expected.to validate_presence_of(:abbr) }
    it 'validates uniqueness of abbreviation' do
      license.save
      license2 = FactoryBot.build(:license, abbr: license.abbr.downcase)
      expect(license2).to_not be_valid
      expect(license2.errors.full_messages).to include 'Abbr has already been taken'
    end

    it 'converts all characters to upper case' do
      license.abbr.downcase!
      license.save
      expect(license.abbr).to_not eq license.abbr.downcase
      expect(license.abbr).to eq license.abbr.upcase
    end
  end
  describe 'Title' do
    it { is_expected.to validate_presence_of :title }
  end

  describe '#license_description' do
    it 'returns abbreviation and title' do
      expect(license.license_description)
        .to match(/^#{Regexp.quote(license.abbr)}.*#{Regexp.quote(license.title)}/)
    end
  end
end
