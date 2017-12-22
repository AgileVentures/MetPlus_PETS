require 'rails_helper'

RSpec.describe ApplicationQuestion, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:application_question)).to be_valid
    end
  end
  describe 'Database schema' do
    it { is_expected.to have_db_column :job_application_id }
    it { is_expected.to have_db_column :question_id }
    it { is_expected.to have_db_column :answer }
  end
  describe 'Associations' do
    it { is_expected.to belong_to :job_application }
    it { is_expected.to belong_to :question }
  end
  describe 'Validations' do
    it { is_expected.to validate_presence_of :job_application }
    it { is_expected.to validate_presence_of :question }
    it { is_expected.to validate_inclusion_of(:answer).in_array([true, false]) }
  end
end
