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
    describe 'dependent: :destroy' do
      f = ->(obj) { FactoryBot.create(obj) }
      let(:q) { f[:question] }
      let(:jq) { FactoryBot.create(:job_question, job: f[:job], question: q) }
      let(:aq) do
        FactoryBot.create(:application_question,
                          job_application: f[:job_application],
                          question: q)
      end
      it 'destroys jobs with join association when question is destroyed' do
        jobs = jq.question.jobs
        expect { jq.question.destroy }.to \
          change { jobs.count }.from(1).to(0).and \
            change { JobQuestion.count }.by(-1)
      end
      it 'destroys job_applications with join association when question is destroyed' do
        job_applications = aq.question.job_applications
        expect { aq.question.destroy }.to \
          change { job_applications.count }.from(1).to(0).and \
            change { ApplicationQuestion.count }.by(-1)
      end
    end
  end
end
