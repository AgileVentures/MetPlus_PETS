require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:question) { FactoryGirl.build(:question) }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(question).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :question_text }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:job_questions) }
    it { is_expected.to have_many(:jobs).through(:job_questions).dependent(:destroy) }

    it { is_expected.to have_many(:application_questions) }
    it { is_expected.to have_many(:job_applications)
      .through(:application_questions).dependent(:destroy) }
  end
end
