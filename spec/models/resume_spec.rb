require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Resume, type: :model do
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :file_name }
    it { is_expected.to have_db_column :job_seeker_id }
  end

  describe 'Resume instance' do
    it 'is valid with all required fields' do
      stub_cruncher_authenticate
      stub_cruncher_file_upload

      file = fixture_file_upload('files/Janitor-Resume.doc')
      resume = Resume.new(file_name: 'testfile.doc',
                          job_seeker_id: FactoryBot.create(:job_seeker).id,
                          file: file)

      expect(resume).to be_valid
    end
    it 'is invalid without all required fields' do
      file = fixture_file_upload('files/Janitor-Resume.doc')

      resume = Resume.new(file_name: 'testfile.doc',
                          job_seeker_id: FactoryBot.create(:job_seeker).id)
      expect(resume).not_to be_valid
      resume = Resume.new(file_name: nil,
                          job_seeker_id: FactoryBot.create(:job_seeker).id,
                          file: file)
      expect(resume).not_to be_valid
      resume = Resume.new(file_name: 'testfile.doc',
                          job_seeker_id: nil,
                          file: file)
      expect(resume).not_to be_valid
    end
  end

  context 'saving model instance and resume file' do
    let(:job_seeker) { FactoryBot.create(:job_seeker) }

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_file_upload
    end

    it 'succeeds with valid model and file type' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be true
      expect(Resume.count).to eq 1
    end

    it 'fails with invalid model and valid file type' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: nil)
      expect(resume.save).to be false
      expect(resume.errors.full_messages)
        .to contain_exactly("Job seeker can't be blank")
      expect(Resume.count).to eq 0
    end

    it 'fails with valid model and invalid file type' do
      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'Test File.zzz',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be false
      expect(Resume.count).to eq 0
    end

    it 'fails with invalid model and invalid file type' do
      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'nil',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be false
      expect(Resume.count).to eq 0
    end

    it 'raises an error when the external cruncher raises an exception' do
      stub_cruncher_file_upload_error
      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: job_seeker.id)
      expect do
        resume.save
      end .to raise_error(RuntimeError)
      expect(resume.errors.full_messages)
        .to contain_exactly('File could not be uploaded - see system admin')
      expect(resume.destroyed?).to be true
    end
  end

  describe '#save!' do
    let(:job_seeker) { FactoryBot.create(:job_seeker) }

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_file_upload
    end

    it 'saves the record with valid attributes and file type' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: job_seeker.id)
      expect(resume.save!).to be true
      expect(Resume.count).to eq 1
    end

    it 'raises an exception with invalid job_seeker_id' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: nil)
      expect { resume.save! }
        .to raise_error(
          ActiveRecord::RecordInvalid,
          "Validation failed: Job seeker can't be blank"
        )
      expect(Resume.count).to eq 0
    end

    it 'raises an exception with invalid file type' do
      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'Test File.zzz',
                          job_seeker_id: job_seeker.id)
      expect { resume.save! }
        .to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: File name unsupported file type'
        )
      expect(Resume.count).to eq 0
    end

    it 'raises an exception when the external cruncher raises an exception' do
      stub_cruncher_file_upload_error
      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: job_seeker.id)
      expect { resume.save! }
        .to raise_error(RuntimeError, 'Resume could not be uploaded')
      expect(resume.destroyed?).to be true
    end
  end
end
