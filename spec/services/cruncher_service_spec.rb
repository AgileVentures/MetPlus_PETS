require 'rails_helper'

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

  describe 'Initialization' do
    it 'Establishes service URL' do
      expect(CruncherService.service_url).to eq ENV['CRUNCHER_SERVICE_URL']
    end
  end

  context 'Cruncher HTTP calls' do

    describe 'authorization' do
      it 'returns HTTP success' do
        expect(auth_result.code).to eq 200
      end

      it 'returns authorization token' do
        expect(JSON.parse(auth_result)['token']).not_to be_nil
      end

      it 'raises error with invalid credentials' do
        expect {RestClient.post(CruncherService.service_url +
                          '/authenticate', {},
                          {'X-Auth-Username' => 'nobody',
                           'X-Auth-Password' => 'none'})}.
                                to raise_error(RuntimeError)
      end
    end

    describe 'upload file' do
      it 'returns HTTP success' do
        expect(upload_result.code).to eq 200
      end

      it 'returns cruncher success message' do
        expect(JSON.parse(upload_result)['resultCode']).to eq 'SUCCESS'
      end
    end
  end

  context 'CruncherService API calls' do

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
        file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
        expect(CruncherService.upload_file(file,
                                    'Admin-Assistant-Resume.pdf',
                                    'test_id')).to be true
      end

      it 'raises error for invalid file type' do
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
      it 'retries for expired auth_token' do
        file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
        expect(CruncherService.upload_file(file,
                                    'Admin-Assistant-Resume.pdf',
                                    'test_id')).to be true

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
end
