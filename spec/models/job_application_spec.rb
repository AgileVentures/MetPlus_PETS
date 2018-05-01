require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplication, type: :model do
  before do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:job_application)).to be_valid
    end
  end
  describe 'Database schema' do
    it { is_expected.to have_db_column :job_seeker_id }
    it { is_expected.to have_db_column :job_id }
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :reason_for_rejection }
  end
  describe 'Associations' do
    it { is_expected.to belong_to :job_seeker }
    it { is_expected.to belong_to :job }
    it { is_expected.to have_many(:status_changes).dependent(:destroy) }
    it { is_expected.to have_many(:application_questions) }
    it {
      is_expected.to have_many(:questions)
        .through(:application_questions).dependent(:destroy)
    }
    describe 'dependent: :destroy' do
      let(:aq) do
        FactoryBot.create(:application_question,
                          job_application: FactoryBot.create(:job_application),
                          question: FactoryBot.create(:question))
      end
      it 'destroys questions with join association when job_application is destroyed' do
        questions = aq.job_application.questions
        expect { aq.job_application.destroy }.to \
          change { questions.count }.from(1).to(0).and \
            change { ApplicationQuestion.count }.by(-1)
      end
      it 'destroys status_changes with association when job_application is destroyed' do
        statuses = aq.job_application.status_changes
        expect { aq.job_application.destroy }.to \
          change { statuses.count }.from(1).to(0).and \
            change { StatusChange.count }.by(-1)
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:job_seeker_id).scoped_to(:job_id) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:job) { FactoryBot.create(:job, company: FactoryBot.create(:company)) }
    subject do
      FactoryBot.build(
        :job_application,
        job: job,
        job_seeker: job_seeker,
        status: :active
      )
    end

    describe 'status' do
      it 'Status -1 should generate exception' do
        expect { subject.status = -1 }
          .to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
      end
      it 'Status 0 should be active' do
        subject.status = 0
        expect(subject.status).to eq 'active'
      end
      it 'Status 1 should be accepted' do
        subject.status = 1
        expect(subject.status).to eq 'accepted'
      end
      it 'Status 2 should be not_accepted' do
        subject.status = 2
        expect(subject.status).to eq 'not_accepted'
      end
      it 'Status 3 should be processing' do
        subject.status = 3
        expect(subject.status).to eq 'processing'
      end
      it 'Status 4 should generate exception' do
        expect { subject.status = 4 }
          .to raise_error(ArgumentError).with_message('\'4\' is not a valid status')
      end
    end
  end

  describe '#active?' do
    let(:active_job) { FactoryBot.create(:job) }
    let(:inactive_job) { FactoryBot.create(:job, status: :filled) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:valid_application) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker)
    end
    let(:invalid_application1) do
      FactoryBot.create(:job_application,
                        job: inactive_job, job_seeker: job_seeker)
    end
    let(:invalid_application2) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker,
                        status: 'accepted')
    end

    context 'with active job and active application status' do
      it 'returns true' do
        expect(valid_application.active?).to be true
      end
    end
    context 'with inactive job and active application status' do
      it 'returns false' do
        expect(invalid_application1.active?).to be false
      end
    end
    context 'with inactive job and inactive application status' do
      it 'returns false' do
        expect(invalid_application2.active?).to be false
      end
    end
  end

  describe '#accept' do
    let(:active_job) { FactoryBot.create(:job) }
    let(:job_seeker1) { FactoryBot.create(:job_seeker) }
    let(:job_seeker2) { FactoryBot.create(:job_seeker) }
    let(:application1) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker1)
    end
    let(:application2) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker2)
    end

    it 'updates the selected application status to be accepted' do
      expect { application1.accept }.to change { application1.status }
        .from('active').to('accepted')
    end
    it 'updates unselected application status to be not accepted' do
      expect { application1.accept }.to change {
        application1.job.job_applications
                    .find(application2.id).status
      }
        .from('active').to('not_accepted')
    end
    it 'updates the selected job status to be filled' do
      expect { application1.accept }.to change { application1.job.status }
        .from('active').to('filled')
    end
  end

  describe 'tracking status change history' do
    let(:job)  { FactoryBot.create(:job) }
    let(:js) { FactoryBot.create(:job_seeker) }
    let!(:ja1) { FactoryBot.create(:job_application, job: job) }

    before(:each) do
      sleep(1)
      ja1.accept
    end

    it 'adds a status change record for a new application' do
      expect { FactoryBot.create(:job_application, job: job, job_seeker: js) }
        .to change(StatusChange, :count).by 1
    end

    it 'tracks status change times for an application' do
      expect(ja1.status_change_time(:active))
        .to eq StatusChange.second.created_at

      expect(ja1.status_change_time(:accepted))
        .to eq StatusChange.third.created_at
    end
  end

  describe '#reject' do
    let(:active_job) { FactoryBot.create(:job) }
    let(:job_seeker1) { FactoryBot.create(:job_seeker) }
    let(:job_seeker2) { FactoryBot.create(:job_seeker) }
    let(:application1) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker1)
    end
    let(:application2) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker2)
    end

    it 'updates the selected application status to be rejected' do
      expect { application1.reject }.to change { application1.status }
        .from('active').to('not_accepted')
    end
  end

  describe '#processing' do
    let(:active_job) { FactoryBot.create(:job) }
    let(:job_seeker1) { FactoryBot.create(:job_seeker) }
    let(:application1) do
      FactoryBot.create(:job_application,
                        job: active_job, job_seeker: job_seeker1)
    end

    it 'updates the selected application status to be processing' do
      expect do
        application1.process
      end.to change { application1.status }.from('active').to('processing')
    end
  end

  describe 'find_by_company_id' do
    let(:widgetCompany) { FactoryBot.create(:company) }
    let(:steelCompany) { FactoryBot.create(:company) }
    let(:job1) { FactoryBot.create(:job, company: widgetCompany) }
    let(:job2) { FactoryBot.create(:job, company: widgetCompany) }
    let(:job3) { FactoryBot.create(:job, company: steelCompany) }
    let(:job_seeker1) { FactoryBot.create(:job_seeker) }
    let(:job_seeker2) { FactoryBot.create(:job_seeker) }
    let(:application1) do
      FactoryBot.create(:job_application,
                        job: job1, job_seeker: job_seeker1)
    end
    let(:application2) do
      FactoryBot.create(:job_application,
                        job: job2, job_seeker: job_seeker2)
    end
    let(:application3) do
      FactoryBot.create(:job_application,
                        job: job3, job_seeker: job_seeker2)
    end

    it 'updates the selected application status to be rejected' do
      applications = JobApplication.find_by_company(widgetCompany)
      expect(applications).to match_array([application1, application2])
    end
  end
end
