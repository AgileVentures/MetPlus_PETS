require 'rails_helper'

RSpec.describe JobQuestion, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:job_question)).to be_valid
    end
  end
  describe 'Database schema' do
    it { is_expected.to have_db_column :job_id }
    it { is_expected.to have_db_column :question_id }
  end
  describe 'Associations' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :question }
  end
end
