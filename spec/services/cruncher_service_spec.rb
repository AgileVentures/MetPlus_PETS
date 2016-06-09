require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe CruncherService, type: :request do

  let(:auth_result) {RestClient.post(CruncherService.service_url +
                    '/authenticate', {},
                    {'X-Auth-Username' => ENV['CRUNCHER_SERVICE_USERNAME'],
                     'X-Auth-Password' => ENV['CRUNCHER_SERVICE_PASSWORD']})}

  let(:upload_result) {RestClient.post(CruncherService.service_url +
        '/curriculum/upload',
      { 'file'   => fixture_file_upload('files/Admin-Assistant-Resume.pdf'),
        'name'   => 'Admin-Assistant-Resume.pdf',
        'userId' => 'test_id' },
      { 'Accept' => 'application/json',
        'X-Auth-Token' => JSON.parse(auth_result)['token'],
        'Content-Type' => 'application/pdf' })}

  let(:job_result) {RestClient.post(CruncherService.service_url +
        '/job/create',
      { 'jobId'   => 10,
        'title'   => 'Software Engineer',
        'description' => 'description of the job' },
      { 'Accept' => 'application/json',
        'X-Auth-Token' => JSON.parse(auth_result)['token']
        })}


  describe 'Initialization' do
    it 'Establishes service URL' do
      expect(CruncherService.service_url).to eq ENV['CRUNCHER_SERVICE_URL']
    end
  end

  context 'Cruncher HTTP calls' do
    describe 'authentication success' do
      before(:each) do
        stub_cruncher_authenticate
      end
      it 'returns HTTP success' do
        expect(auth_result.code).to eq 200
      end
      it 'returns authorization token' do
        expect(JSON.parse(auth_result)['token']).not_to be_nil
      end
    end

    describe 'authentication failure' do
      it 'raises error with invalid credentials' do

        stub_cruncher_authenticate_error

        expect {RestClient.post(CruncherService.service_url +
                          '/authenticate', {},
                          {'X-Auth-Username' => 'nobody',
                           'X-Auth-Password' => 'none'})}.
                                to raise_error(RuntimeError)
      end
    end

    describe 'upload file' do

      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_upload
      end

      it 'returns HTTP success' do
        expect(upload_result.code).to eq 200
      end

      it 'returns cruncher success message' do
        expect(JSON.parse(upload_result)['resultCode']).to eq 'SUCCESS'
      end
    end

    describe 'create job' do

      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
      end

      it 'returns HTTP success' do
        expect(job_result.code).to eq 200
      end

      it 'returns cruncher success message' do
        expect(JSON.parse(job_result)['resultCode']).to eq 'SUCCESS'
      end
    end
   end

  context 'CruncherService API calls' do

    before(:each) do
      stub_cruncher_authenticate
    end

    describe 'Cruncher authentication' do
      around(:each) do |test|
        CruncherService.auth_token = nil
        test.run
        CruncherService.auth_token = nil
      end

      it 'authenticates only once' do
        allow(RestClient).to receive(:post).
              and_return(auth_result)
        CruncherService.auth_token
        CruncherService.auth_token
        CruncherService.auth_token
        expect(RestClient).to have_received(:post).once
      end
    end

    describe 'File upload' do
      it 'returns success (true) for valid file type' do
        stub_cruncher_file_upload

        file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
        expect(CruncherService.upload_file(file,
                                    'Admin-Assistant-Resume.pdf',
                                    'test_id')).to be true
      end

      it 'raises error for invalid file type' do
        stub_cruncher_file_upload_error

        file = fixture_file_upload('files/Example Excel File.xls')
        expect{ CruncherService.upload_file(file,
                                    'Example Excel File.xls',
                                    'test_id') }.
                      to raise_error(RuntimeError)
      end

      it 'raises error for unknown MIME type' do

        file = fixture_file_upload('files/Test File.zzz')
        expect{ CruncherService.upload_file(file,
                                    'Test File.zzz',
                                    'test_id') }.
                      to raise_error(RuntimeError)
      end
    end

    describe 'create job' do
      it 'returns success (true) for valid create job' do
        stub_cruncher_job_create

        expect(JobCruncher.create_job(10,'Software Engineer',
              'description of the job')).to be true
      end

      it 'raises error for invalid job id' do
        stub_cruncher_job_create_error

        expect{ CruncherService.create_job('jobId',
                                    'title',
                                    'description') }.
                      to raise_error(RuntimeError)
      end
    end
  end

  context 'Cruncher service recover expired token' do
    it 'retries for expired auth_token' do
      stub_cruncher_authenticate
      stub_cruncher_file_upload_retry_auth

      CruncherService.auth_token = 'expired'

      expect(CruncherService).to receive(:auth_token).
                    twice.and_call_original

      file = fixture_file_upload('files/Janitor-Resume.doc')
      expect(CruncherService.upload_file(file,
                                  'Janitor-Resume.doc',
                                 'test_id')).to be true

    end
  end
 end
