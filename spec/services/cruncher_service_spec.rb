require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe CruncherService, type: :request do
  let(:auth_result) do
    RestClient.post(CruncherService.service_url +
                    '/authenticate', {},
                    'X-Auth-Username' => ENV['CRUNCHER_SERVICE_USERNAME'],
                    'X-Auth-Password' => ENV['CRUNCHER_SERVICE_PASSWORD'])
  end

  let(:testfile_pdf)     { 'files/Admin-Assistant-Resume.pdf' }
  let(:testfile_word)    { 'files/Janitor-Resume.doc' }
  let(:testfile_wordxml) { 'files/Sales-Manager-Resume.docx' }

  let(:download_result) do
    RestClient.get(CruncherService.service_url +
        '/resume/1',
                   'X-Auth-Token' => JSON.parse(auth_result)['token'])
  end

  let(:upload_result) do
    RestClient.post(CruncherService.service_url +
                    '/resume/upload',
                    { 'file' => fixture_file_upload(testfile_pdf),
                      'name' => testfile_pdf,
                      'userId' => 'test_id' },
                    'Accept' => 'application/json',
                    'X-Auth-Token' => JSON.parse(auth_result)['token'],
                    'Content-Type' => 'application/pdf')
  end

  let(:job_result) do
    RestClient.post(CruncherService.service_url +
                    '/job/create',
                    { 'jobId' => 10,
                      'title' => 'Software Engineer',
                      'description' => 'description of the job' },
                    'Accept' => 'application/json',
                    'X-Auth-Token' => JSON.parse(auth_result)['token'])
  end

  let(:job_update_result) do
    RestClient.patch(CruncherService.service_url +
                     '/job/10/update',
                     { 'jobId' => 10,
                       'title' => 'Software Engineer',
                       'description' => 'revised description of the job' },
                     'Accept' => 'application/json',
                     'X-Auth-Token' => JSON.parse(auth_result)['token'])
  end

  let(:match_jobs_result) do
    RestClient.get(CruncherService.service_url +
                   '/job/match/1',
                   'X-Auth-Token' => JSON.parse(auth_result)['token'])
  end

  let(:match_resumes_result) do
    RestClient.get(CruncherService.service_url +
                   '/resume/match/1',
                   'Accept' => 'application/json',
                   'X-Auth-Token' => JSON.parse(auth_result)['token'])
  end

  let(:match_resume_and_job_result) do
    RestClient.get(CruncherService.service_url + '/resume/1/compare/1',
                   'Accept': 'application/json',
                   'X-Auth-Token': JSON.parse(auth_result)['token'])
  end

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

        expect do
          RestClient.post(CruncherService.service_url +
                          '/authenticate', {},
                          'X-Auth-Username' => 'nobody',
                          'X-Auth-Password' => 'none')
        end
          .to raise_error(RuntimeError)
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

    describe 'download file: PDF' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_download(testfile_pdf)
      end

      it 'returns HTTP success' do
        expect(download_result.code).to eq 200
      end

      it 'returns file contents' do
        file = fixture_file_upload(testfile_pdf)
        expect(download_result).to eq file.read
      end
    end
    describe 'download file: MS Word' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_download(testfile_word)
      end

      it 'returns HTTP success' do
        expect(download_result.code).to eq 200
      end

      it 'returns file contents' do
        file = fixture_file_upload(testfile_word)
        expect(download_result).to eq file.read
      end
    end
    describe 'download file: MS Word - XML' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_file_download(testfile_wordxml)
      end

      it 'returns HTTP success' do
        expect(download_result.code).to eq 200
      end

      it 'returns file contents' do
        file = fixture_file_upload(testfile_wordxml)
        expect(download_result).to eq file.read
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

    describe 'update job' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_update
      end

      it 'returns HTTP success' do
        expect(job_update_result.code).to eq 200
      end

      it 'returns cruncher success message' do
        expect(JSON.parse(job_update_result)['resultCode']).to eq 'SUCCESS'
      end
    end

    describe 'match jobs' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_match_jobs
      end

      it 'returns HTTP success' do
        expect(match_jobs_result.code).to eq 200
      end

      it 'returns success message' do
        expect(JSON.parse(match_jobs_result)['resultCode']).to eq 'SUCCESS'
      end
    end

    describe 'match resumes' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_match_resumes
      end

      it 'returns HTTP success' do
        expect(match_resumes_result.code).to eq 200
      end

      it 'returns success message in response' do
        expect(JSON.parse(match_resumes_result)['resultCode']).to eq 'SUCCESS'
      end
    end

    describe 'match resume and job' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_match_resume_and_job
      end

      it 'returns HTTP success' do
        expect(match_resume_and_job_result.code).to eq 200
      end

      it 'returns success result code in response' do
        expect(JSON.parse(match_resume_and_job_result)['resultCode'])
          .to eq 'SUCCESS'
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
        allow(RestClient).to receive(:post)
          .and_return(auth_result)
        CruncherService.auth_token
        CruncherService.auth_token
        CruncherService.auth_token
        expect(RestClient).to have_received(:post).once
      end

      it 'raises exception for unauthorized exception' do
        stub_cruncher_authenticate_error
        expect { CruncherService.auth_token }
          .to raise_error('Invalid credentials for Cruncher access')
      end
    end

    describe 'File upload' do
      it 'returns success (true) for valid file type' do
        stub_cruncher_file_upload

        file = fixture_file_upload(testfile_pdf)
        expect(CruncherService.upload_file(file,
                                           testfile_pdf,
                                           'test_id')).to be true
      end

      it 'raises error for invalid file type' do
        stub_cruncher_file_upload_error

        file = fixture_file_upload('files/Example Excel File.xls')
        expect do
          CruncherService.upload_file(file,
                                      'Example Excel File.xls',
                                      'test_id')
        end
          .to raise_error(RuntimeError)
      end

      it 'raises error for unknown MIME type' do
        file = fixture_file_upload('files/Test File.zzz')
        expect do
          CruncherService.upload_file(file,
                                      'Test File.zzz',
                                      'test_id')
        end
          .to raise_error(RuntimeError)
      end
    end

    describe 'File download' do
      it 'returns Tempfile instance when successful' do
        stub_cruncher_file_download(testfile_pdf)

        expect(CruncherService.download_file(1).class).to be Tempfile
      end
      it 'returns nil if résumé is not found' do
        stub_cruncher_file_download_notfound

        expect(CruncherService.download_file(2)).to be_nil
      end
    end

    describe 'create job' do
      it 'returns success (true) for valid create job' do
        stub_cruncher_job_create

        expect(CruncherService.create_job(10, 'Software Engineer',
                                          'description of the job')).to be true
      end

      it 'fails if jobId already exists' do
        stub_cruncher_job_create_fail('JOB_ID_EXISTS')

        expect(CruncherService.create_job(10, 'title', 'test')).to be false
      end
    end

    describe 'update job' do
      it 'returns success (true) for successful job update' do
        stub_cruncher_job_update

        expect(CruncherService.update_job(10, 'Software Engineer',
                                          'revised description')).to be true
      end

      it 'fails if jobId cannot be found' do
        stub_cruncher_job_update_fail('JOB_NOT_FOUND')

        expect(CruncherService.update_job(1, 'title', 'test')).to be false
      end
    end

    describe 'update job' do
      it 'returns success (true) for successful job update' do
        stub_cruncher_job_update

        expect(CruncherService.update_job(10, 'Software Engineer',
                                          'revised description')).to be true
      end

      it 'fails if jobId cannot be found' do
        stub_cruncher_job_update_fail('JOB_NOT_FOUND')

        expect(CruncherService.update_job(1, 'title', 'test')).to be false
      end
    end

    describe 'match jobs' do
      it 'returns matching jobs for a valid request' do
        stub_cruncher_match_jobs
        expect { CruncherService.match_jobs(1).not_to be nil }
      end

      it 'returns nil if cannot find resume' do
        stub_cruncher_match_jobs_fail('RESUME_NOT_FOUND')

        expect { CruncherService.match_jobs(1).to be nil }
      end
    end

    describe 'match resumes' do
      it 'returns success' do
        stub_cruncher_match_resumes

        expect(CruncherService.match_resumes(1)).not_to be nil
      end
      it 'returns nil if cannot find job' do
        stub_cruncher_match_resumes_fail('JOB_NOT_FOUND')

        expect { CruncherService.match_resumes(1).to be nil }
      end
    end

    describe 'match résumé and job' do
      it 'returns success and match results' do
        stub_cruncher_match_resume_and_job

        result = CruncherService.match_resume_and_job(1, 1)

        expect(result[:status]).to eq 'SUCCESS'
        expect(result[:stars])
          .to include 'NaiveBayes' => 3.4, 'ExpressionCruncher' => 2.3
      end

      it 'returns error message if job not found' do
        stub_cruncher_match_resume_and_job_error(:no_job, 10_000)

        result = CruncherService.match_resume_and_job(1, 10_000)

        expect(result[:status]).to eq 'ERROR'
        expect(result[:message]).to eq 'No job found with id: 10000'
      end
    end
  end

  context 'Cruncher service tries to recover expired token' do
    context 'file upload' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_file_upload_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        file = fixture_file_upload('files/Janitor-Resume.doc')
        expect(CruncherService.upload_file(file,
                                           'Janitor-Resume.doc',
                                           'test_id')).to be true
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_file_upload_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        file = fixture_file_upload('files/Janitor-Resume.doc')
        expect do
          CruncherService.upload_file(file,
                                      'Janitor-Resume.doc',
                                      'test_id')
        end .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'file download' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_file_download_retry_auth(testfile_pdf)

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        file = fixture_file_upload(testfile_pdf)
        expect(CruncherService.download_file(1).open.read)
          .to eq file.read
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_file_download_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect { CruncherService.download_file(1) }
          .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'create job' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_job_create_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect(CruncherService.create_job(10, 'Software Engineer',
                                          'description of the job')).to be true
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_job_create_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect do
          CruncherService.create_job(10, 'Software Engineer',
                                     'description of the job')
        end .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'update job' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_job_update_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect(CruncherService.update_job(10, 'Software Engineer',
                                          'revised description')).to be true
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_job_update_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect do
          CruncherService.update_job(10, 'Software Engineer',
                                     'revised description')
        end .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'match resume and job' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_match_resume_and_job_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        result = CruncherService.match_resume_and_job(1, 1)

        expect(result[:status]).to eq 'SUCCESS'
        expect(result[:stars])
          .to include 'NaiveBayes' => 3.4, 'ExpressionCruncher' => 2.3
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_match_resume_and_job_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect { CruncherService.match_resume_and_job(1, 1) }
          .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'match jobs' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_match_jobs_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect(CruncherService.match_jobs(1)).not_to be nil
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_match_jobs_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect { CruncherService.match_jobs(1) }
          .to raise_error(RestClient::Unauthorized)
      end
    end

    context 'match resumes' do
      it 'reauthorizes if expired auth_token' do
        stub_cruncher_authenticate
        stub_cruncher_match_resumes_retry_auth

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect(CruncherService.match_resumes(1)).not_to be nil
      end
      it 're-raises auth exception if auth retry fails' do
        stub_cruncher_authenticate
        stub_cruncher_match_resumes_retry_auth_fail

        CruncherService.auth_token = 'expired'

        expect(CruncherService).to receive(:auth_token)
          .twice.and_call_original

        expect { CruncherService.match_resumes(1) }
          .to raise_error(RestClient::Unauthorized)
      end
    end
  end
end
