require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:question) { FactoryBot.build(:question) }

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
    it {
      is_expected.to have_many(:job_applications)
        .through(:application_questions).dependent(:destroy)
    }
  end
	
  describe 'When a question is destroyed' do
    let(:question)             { FactoryBot.create(:question) }
    let(:job)                  { FactoryBot.create(:job) }
    let(:job_question)         { FactoryBot.create(:job_question, question: question, job: job)}
    let(:job_application)      { FactoryBot.create(:job_application) }
    let(:application_question) { FactoryBot.create(:application_question, question: question, job_application: job_application) }
    it 'jobs :through association with dependent::destroy deletes record' do
      expect(job_question).to	be_valid
      job_ques_id = question.job_questions.first.id  
      question.destroy
      expect{JobQuestion.find(job_ques_id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'job_application :through association with dependent::destroy deletes record' do
      expect(application_question).to be_valid
      app_ques_id = question.application_questions.first.id
      question.destroy
      expect{ApplicationQuestion.find(app_ques_id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
