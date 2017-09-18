require 'rails_helper'

RSpec.describe JobShift, type: :model do
  let(:job_shift) { FactoryGirl.create(:job_shift) }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:job_shift)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many(:jobs) }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :shift }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :shift }
  end
end
