require 'rails_helper'

RSpec.describe Resume, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:resume)).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :file_name }
    it { is_expected.to have_db_column :job_seeker_id }
  end

  describe 'Resume instance' do

    it 'is valid with all required fields' do

      stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      file = fixture_file_upload('files/Janitor-Resume.doc')
      resume = Resume.new(file_name: 'testfile.doc',
              job_seeker_id: FactoryGirl.create(:job_seeker).id,
              file: file)

      expect(resume).to be_valid
    end
    it 'is invalid without all required fields' do

      file = fixture_file_upload('files/Janitor-Resume.doc')

      resume = Resume.new(file_name: 'testfile.doc',
              job_seeker_id: FactoryGirl.create(:job_seeker).id)
      expect(resume).not_to be_valid
      resume = Resume.new(file_name: nil,
              job_seeker_id: FactoryGirl.create(:job_seeker).id,
              file: file)
      expect(resume).not_to be_valid
      resume = Resume.new(file_name: 'testfile.doc',
              job_seeker_id: nil,
              file: file)
      expect(resume).not_to be_valid

    end
  end

  context 'saving model instance and resume file' do
    let(:job_seeker) {FactoryGirl.create(:job_seeker)}

    before(:each) do
      stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end

    it 'succeeds with valid model and file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be true
      expect(Resume.count).to eq 1
    end

    it 'fails with invalid model and valid file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      resume = Resume.new(file: file,
                          file_name: 'Admin-Assistant-Resume.pdf',
                          job_seeker_id: nil)
      expect(resume.save).to be false
      expect(resume.errors.full_messages).
              to contain_exactly("Job seeker can't be blank")
      expect(Resume.count).to eq 0
    end

    it 'fails with valid model and invalid file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_raise(RuntimeError)

      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'Test File.zzz',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be false
      expect(Resume.count).to eq 0
    end

    it 'fails with invalid model and invalid file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_raise(RuntimeError)

      file = fixture_file_upload('files/Test File.zzz')
      resume = Resume.new(file: file,
                          file_name: 'nil',
                          job_seeker_id: job_seeker.id)
      expect(resume.save).to be false
      expect(Resume.count).to eq 0
    end
  end

end
