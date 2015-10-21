require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:skill)).to be_valid
    end
  end

  describe 'Associations' do

  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end
end
