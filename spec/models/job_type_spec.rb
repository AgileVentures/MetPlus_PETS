require 'rails_helper'

RSpec.describe JobType, type: :model do
  let(:job_type) { FactoryBot.create(:job_type) }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:job_type)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many(:jobs) }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :job_type }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :job_type }
  end
end
