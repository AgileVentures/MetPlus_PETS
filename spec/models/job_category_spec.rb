require 'rails_helper'

RSpec.describe JobCategory, type: :model do
  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many :skills }
    it { is_expected.to have_many :jobs }
    it {
      is_expected.to have_and_belong_to_many(:agency_people)
        .join_table('job_specialities')
    }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end

  describe 'Validations' do
    subject { FactoryBot.build(:job_category) }

    describe 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
    describe 'Description' do
      it { is_expected.to validate_presence_of(:description) }
    end
  end
end
