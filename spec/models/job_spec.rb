require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Job, type: :model do
  let(:job) { FactoryGirl.create(:job) }
  let!(:job_seeker) { FactoryGirl.create(:job_seeker) }
  let!(:job_seeker_resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }
  let!(:job_seeker2) { FactoryGirl.create(:job_seeker) }
  let!(:job_seeker2_resume) { FactoryGirl.create(:resume, job_seeker: job_seeker2) }
  let!(:test_file) { '../fixtures/files/Admin-Assistant-Resume.pdf' }

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:job)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :company_person }
    it { is_expected.to belong_to :address }
    it { is_expected.to belong_to :job_category }
    it { is_expected.to have_many(:job_skills).dependent(:destroy) }
    it do
      is_expected.to accept_nested_attributes_for(:job_skills)
        .allow_destroy(true)
    end
    it { is_expected.to have_many(:skills).through(:job_skills) }
    it do
      is_expected.to have_many(:required_skills).through(:job_skills)
        .conditions(job_skills: { required: true })
        .source(:skill).class_name('Skill')
    end
    it do
      is_expected.to have_many(:nice_to_have_skills)
        .through(:job_skills).conditions(job_skills: { required: false })
        .source(:skill).class_name('Skill')
    end
    it { is_expected.to have_many(:job_applications) }
    it { is_expected.to have_many(:job_seekers).through(:job_applications) }
    it { is_expected.to have_many(:status_changes) }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :title }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :company_job_id }
    it { is_expected.to have_db_column :shift }
    it { is_expected.to have_db_column :fulltime }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :company_person_id }
    it { is_expected.to have_db_column :address_id }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_length_of(:description).is_at_most(10_000) }
    it { is_expected.to validate_presence_of :company_job_id }
    it { should allow_value('', nil).for(:fulltime).on(:update) }
    it { should allow_value('', nil).for(:fulltime).on(:create) }
    it { is_expected.to validate_presence_of :company_id }
    it do
      is_expected.to validate_inclusion_of(:shift)
        .in_array(%w(Day Evening Morning))
    end
    describe 'status' do
      it 'Status -1 should generate exception' do
        expect { subject.status = -1 }.to raise_error(ArgumentError)
                              .with_message('\'-1\' is not a valid status')
      end
      it 'Status 0 should be active' do
        subject.status = 0
        expect(subject.status).to eq 'active'
      end
      it 'Status 1 should be filled' do
        subject.status = 1
        expect(subject.status).to eq 'filled'
      end
      it 'Status 2 should be revoked' do
        subject.status = 2
        expect(subject.status).to eq 'revoked'
      end
      it 'Status 3 should generate exception' do
        expect { subject.status = 3 }.to raise_error(ArgumentError)
                              .with_message('\'3\' is not a valid status')
      end
    end
  end

  describe 'Class methods' do
  end

  describe 'Instance methods' do
    describe '#apply' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
        stub_cruncher_file_download test_file
      end

      it 'success - first application' do
        num_applications = job.number_applicants
        job.apply job_seeker
        job.reload
        expect(job.job_seekers).to eq [job_seeker]
        expect(job.number_applicants).to be(num_applications + 1)
      end
      it 'raise error - second application with same job seeker' do
        job.apply job_seeker
        expect { job.apply job_seeker }.to raise_error(ActiveRecord::RecordInvalid)
          .with_message('Validation failed: Job seeker has already been taken')
      end
      it 'two applications, different job seekers' do
        num_applications = job.number_applicants
        first_appl = job.apply job_seeker
        second_appl = job.apply job_seeker2
        job.reload
        expect(job.job_seekers).to eq [job_seeker, job_seeker2]
        expect(job.number_applicants).to be(num_applications + 2)
        expect(job.last_application_by_job_seeker(job_seeker))
          .to eq first_appl
        expect(job.last_application_by_job_seeker(job_seeker2))
          .to eq second_appl
      end
    end
  end
  describe 'Create Job (AR model and CruncherService)' do
    before(:each) do
      stub_cruncher_authenticate
    end

    it 'succeeds with all parameters' do
      stub_cruncher_job_create

      job = FactoryGirl.build(:job)

      expect(job.save).to be true
      expect(Job.count).to eq 1
    end

    it 'fails with invalid model parameters' do
      stub_cruncher_job_create

      job = FactoryGirl.build(:job, title: nil)

      expect(job.save).to be false
      expect(job.errors.full_messages).to include("Title can't be blank")
      expect(Job.count).to eq 0
    end

    it 'fails with valid model but cruncher create failure' do
      stub_cruncher_job_create_fail('JOB_ID_EXISTS')

      job = FactoryGirl.build(:job)

      expect(job.save).to be false
      expect(Job.count).to eq 0
      expect(job.errors.full_messages)
        .to include('Job could not be posted to Cruncher, please try again.')
    end

    it 'fails when cruncher authorization fails' do
      stub_cruncher_authenticate_error

      job = FactoryGirl.build(:job)

      expect(job.save).to be false
      expect(Job.count).to eq 0
      expect(job.errors.full_messages)
        .to include('Job could not be posted to Cruncher, please try again.')
    end
  end

  describe 'Update Job (AR model and CruncherService)' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'succeeds with all parameters' do
      stub_cruncher_job_update

      job.title = 'new title'
      job.description = 'new description'

      expect(job.save).to be true
    end

    it 'fails with invalid model parameters' do
      stub_cruncher_job_update

      job.title = nil

      expect(job.save).to be false
      expect(job.errors.full_messages).to include("Title can't be blank")
    end

    it 'fails with valid model but cruncher update failure' do
      stub_cruncher_job_update_fail('JOB_NOT_FOUND')

      job.title = 'new title'

      expect(job.save).to be false
      expect(job.errors.full_messages)
        .to include('Job could not be posted to Cruncher, please try again.')
    end

    it 'fails when cruncher authorization fails' do
      job.title = 'new title'

      # Stub for auth error here (after job create, before update)
      stub_cruncher_authenticate_error

      expect(job.save).to be false
      expect(job.errors.full_messages)
        .to include('Job could not be posted to Cruncher, please try again.')
    end
  end

  describe 'tracking status change history' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    context 'active to filled' do
      before(:each) do
        sleep(1)
        job.filled
      end

      it 'adds a status change record for a new application' do
        expect { FactoryGirl.create(:job) }
          .to change(StatusChange, :count).by 1
      end

      it 'tracks status change times for the job' do
        expect(job.status_change_time(:active))
          .to eq StatusChange.first.created_at

        expect(job.status_change_time(:filled))
          .to eq StatusChange.second.created_at
      end
    end

    context 'active to revoked' do
      before(:each) do
        sleep(1)
        job.revoked
      end

      it 'tracks status change times for the job' do
        expect(job.status_change_time(:active))
          .to eq StatusChange.first.created_at

        expect(job.status_change_time(:revoked))
          .to eq StatusChange.second.created_at
      end
    end
  end
end
