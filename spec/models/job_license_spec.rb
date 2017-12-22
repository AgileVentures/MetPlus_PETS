require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobLicense, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      expect(FactoryBot.build(:job_license)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :license }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :job_id }
    it { is_expected.to have_db_column :license_id }
  end
end
