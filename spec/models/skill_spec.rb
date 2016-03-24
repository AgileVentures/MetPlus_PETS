require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:skill)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many :job_categories }
    it { is_expected.to have_many :job_skills }
    it { is_expected.to have_many(:jobs).through(:job_skills) }
  end

  describe 'Validations' do
    subject {FactoryGirl.build(:skill)}

    describe 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
    describe 'Description' do
      it { is_expected.to validate_presence_of :description }
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end
end
