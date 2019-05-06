module ServiceStubHelpers
  # NOTE: stub(s) for Pusher are not found here.  To stub (and spy on) a
  #       call to Pusher.trigger, use this statement for each test as needed:
  #
  #       allow(Pusher).to receive(:trigger)

  module Cruncher
    JSON_MATCHED_RESUMES =
      JSON.generate('resultCode' => 'SUCCESS',
                    'message' => 'Success',
                    'resumes' => { 'matcher1' =>
                                   [{ 'resumeId' => '2', 'stars' => 2.0 },
                                    { 'resumeId' => '7', 'stars' => 4.9 },
                                    { 'resumeId' => '5', 'stars' => 3.6 }],
                                   'matcher2' =>
                                   [{ 'resumeId' => '8', 'stars' => 1.8 },
                                    { 'resumeId' => '5', 'stars' => 3.8 },
                                    { 'resumeId' => '6', 'stars' => 1.7 }] })

    JSON_MATCHED_JOBS =
      JSON.generate('resultCode' => 'SUCCESS',
                    'message' => 'Success',
                    'jobs' => { 'matcher1' =>
                                [{ 'id' => '2', 'stars' => 3.8 },
                                 { 'id' => '3', 'stars' => 4.7 },
                                 { 'id' => '6', 'stars' => 3.2 }],
                                'matcher2' =>
                                [{ 'id' => '8', 'stars' => 2.8 },
                                 { 'id' => '9', 'stars' => 2.9 },
                                 { 'id' => '6', 'stars' => 3.4 }] })

    JSON_MATCHED_RESUME_AND_JOB =
      JSON.generate('resultCode' => 'SUCCESS',
                    'message' => 'Success',
                    'stars' => { "NaiveBayes": 3.4,
                                 "ExpressionCruncher": 2.3 })

    JSON_NO_MATCHED_JOBS =
      JSON.generate('resultCode' => 'SUCCESS',
                    'message' => 'Success',
                    'jobs' => { 'matcher1' => [],
                                'matcher2' => [] })

    def url_root
      CruncherService.service_url
    end

    def url_authenticate
      url_root + '/authenticate'
    end

    def url_file_upload
      url_root + '/resume/upload'
    end

    def url_file_download
      %r{#{url_root}/resume/\d+}
    end

    def url_job_create
      url_root + '/job/create'
    end

    def url_job_update
      %r{#{url_root}/job/\d+/update}
    end

    def url_match_resume_job
      %r{#{url_root}/resume/\d+/compare/\d+}
    end

    def url_match_jobs
      %r{#{url_root}/job/match/\d+}
    end

    def url_match_resumes
      %r{#{url_root}/resume/match/\d+}
    end

    def stub_cruncher_authenticate
      stub_request(:post, url_authenticate)
        .to_return(body: '{"token": "12345"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_authenticate_error
      stub_request(:post, url_authenticate)
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_file_upload
      stub_request(:post, url_file_upload)
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_file_upload_retry_auth
      stub_request(:post, url_file_upload)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_file_upload_retry_auth_fail
      stub_request(:post, url_file_upload)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_file_upload_error
      stub_request(:post, url_file_upload)
        .to_raise(RuntimeError)
    end

    def stub_cruncher_file_download(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, url_file_download)
        .to_return(body: file.read, status: 200,
                   headers: { 'Content-Disposition' =>
                        'inline; filename="Admin-Assistant-Resume.pdf"' })
    end

    def stub_cruncher_file_download_notfound
      stub_request(:get, url_file_download)
        .to_return(body: "{\"resultCode\":\"RESUME_NOT_FOUND\",
                            \"message\":\"Unable to find the user '2'\"}",
                   status: 200)
    end

    def stub_cruncher_file_download_retry_auth(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, url_file_download)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: file.read, status: 200,
                   headers: { 'Content-Disposition' =>
                        'inline; filename="Admin-Assistant-Resume.pdf"' })
    end

    def stub_cruncher_file_download_retry_auth_fail
      stub_request(:get, url_file_download)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_job_create
      stub_request(:post, url_job_create)
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_job_create_retry_auth
      stub_request(:post, url_job_create)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_job_create_retry_auth_fail
      stub_request(:post, url_job_create)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_job_create_fail(result_code)
      stub_request(:post, url_job_create)
        .to_return(body: "{\"resultCode\":\"#{result_code}\"}", status: 200,
                   headers: { 'Content-Type' => 'application/json' })
    end

    def stub_cruncher_job_create_error
      stub_request(:post, url_job_create)
        .to_raise(RuntimeError)
    end

    def stub_cruncher_job_update
      stub_request(:patch, url_job_update)
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type' => 'application/json' })
    end

    def stub_cruncher_job_update_retry_auth
      stub_request(:patch, url_job_update)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: '{"resultCode":"SUCCESS"}', status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_job_update_retry_auth_fail
      stub_request(:patch, url_job_update)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_job_update_fail(result_code)
      stub_request(:patch, url_job_update)
        .to_return(body: "{\"resultCode\":\"#{result_code}\"}", status: 200,
                   headers: { 'Content-Type' => 'application/json' })
    end

    def stub_cruncher_match_resume_and_job
      stub_request(:get, url_match_resume_job)
        .to_return(body: JSON_MATCHED_RESUME_AND_JOB, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_resume_and_job_retry_auth
      stub_request(:get, url_match_resume_job)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: JSON_MATCHED_RESUME_AND_JOB, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_resume_and_job_retry_auth_fail
      stub_request(:get, url_match_resume_job)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_match_resume_and_job_error(type, obj_id)
      case type
      when :no_job
        err = JSON.generate('resultCode': 'JOB_NOT_FOUND',
                            'message': "No job found with id: #{obj_id}")
      when :no_resume
        err = JSON.generate('resultCode': 'RESUME_NOT_FOUND',
                            'message': "No resume found with id: #{obj_id}")
      end
      stub_request(:get, url_match_resume_job)
        .to_raise(RestClient::ResourceNotFound.new(err))
    end

    def stub_cruncher_match_jobs
      stub_request(:get, url_match_jobs)
        .to_return(body: JSON_MATCHED_JOBS, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_jobs_retry_auth
      stub_request(:get, url_match_jobs)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: JSON_MATCHED_JOBS, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_jobs_retry_auth_fail
      stub_request(:get, url_match_jobs)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_match_jobs_fail(result_code)
      stub_request(:get, url_match_jobs)
        .to_return(body: "{\"resultCode\": \"#{result_code}\"}", status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_no_match_jobs
      stub_request(:get, url_match_jobs)
        .to_return(body: JSON_NO_MATCHED_JOBS, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_resumes
      stub_request(:get, url_match_resumes)
        .to_return(body: JSON_MATCHED_RESUMES, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_resumes_retry_auth
      stub_request(:get, url_match_resumes)
        .to_raise(RestClient::Unauthorized).then
        .to_return(body: JSON_MATCHED_RESUMES, status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end

    def stub_cruncher_match_resumes_retry_auth_fail
      stub_request(:get, url_match_resumes)
        .to_raise(RestClient::Unauthorized).then
        .to_raise(RestClient::Unauthorized)
    end

    def stub_cruncher_match_resumes_fail(result_code)
      stub_request(:get, url_match_resumes)
        .to_return(body: "{\"resultCode\": \"#{result_code}\"}", status: 200,
                   headers: { 'Content-Type': 'application/json' })
    end
  end

  module EmailValidator
    def stub_email_validate_valid
      body_json = "{\n  \"address\": \"address@gmail.com\",
                    \n  \"did_you_mean\": null,
                    \n  \"is_valid\": true,
                    \n  \"parts\":
                      {\n    \"display_name\": null,
                       \n    \"domain\": null,
                       \n    \"local_part\": null
                       \n  }
                    \n}"
      stub_request(:get,
                   %r{^https://#{EMAIL_VALIDATE_URL}/address/validate?.*})
        .to_return(body: body_json)
    end

    def stub_email_validate_invalid
      body_json = "{\n  \"address\": \"myaddress@gmal.com\",
                    \n  \"did_you_mean\": \"myaddress@gmail.com\",
                    \n  \"is_valid\": false,
                    \n  \"parts\":
                      {\n    \"display_name\": null,
                       \n    \"domain\": null,
                       \n    \"local_part\": null
                       \n  }
                    \n}"
      stub_request(:get,
                   %r{^https://#{EMAIL_VALIDATE_URL}/address/validate?.*})
        .to_return(body: body_json)
    end

    def stub_email_validate_error
      stub_request(:get,
                   %r{^https://#{EMAIL_VALIDATE_URL}/address/validate?.*})
        .to_raise(RuntimeError)
    end
  end
  module RecaptchaValidator
    def stub_recaptcha_verify
      body_json = "{\n  \"success\": true,
        \n  \"challenge_ts\": \"2017-07-10T05:00:00Z\",
        \n  \"hostname\": \"localhost.c9users.io\"\n }"
      stub_request(:any, %r{https://www.google.com/recaptcha/api/siteverify})
        .to_return(body: body_json)
    end
  end
end
