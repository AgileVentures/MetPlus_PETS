require 'rails_helper'

RSpec.describe Education, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:education)).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :level }
    it { is_expected.to have_db_column :rank }
  end

  describe 'Associations' do
    it { is_expected.to have_many :jobs }
  end
end
