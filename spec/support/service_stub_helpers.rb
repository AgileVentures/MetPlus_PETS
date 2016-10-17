module ServiceStubHelpers

  # NOTE: stub(s) for Pusher are not found here.  To stub (and spy on) a
  #       call to Pusher.trigger, use this statement for each test as needed:
  #
  #       allow(Pusher).to receive(:trigger)

  module Cruncher

    def stub_cruncher_authenticate
      stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_authenticate_error
      stub_request(:post, CruncherService.service_url + '/authenticate').
          to_raise(RuntimeError)
    end
    def stub_cruncher_file_upload
      stub_request(:post, CruncherService.service_url + '/resume/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_file_upload_retry_auth
      stub_request(:post, CruncherService.service_url + '/resume/upload').
          to_raise(RestClient::Unauthorized).then.
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_file_upload_error
      stub_request(:post, CruncherService.service_url + '/resume/upload').
          to_raise(RuntimeError)
    end
    def stub_cruncher_file_download(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, /#{CruncherService.service_url + "/resume/"}\d+/).
          to_return(body: file.read, status: 200,
          :headers => {'Content-Disposition'=>
                        'inline; filename="Admin-Assistant-Resume.pdf"'})
    end
    def stub_cruncher_file_download_notfound
      stub_request(:get, CruncherService.service_url + '/resume/2').
          to_return(body: "{\"resultCode\":\"RESUME_NOT_FOUND\",
                            \"message\":\"Unable to find the user '2'\"}",
                    status: 200)
    end
    def stub_cruncher_file_download_retry_auth(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, CruncherService.service_url + '/resume/1').
          to_raise(RestClient::Unauthorized).then.
          to_return(body: file.read, status: 200,
          :headers => {'Content-Disposition'=>
                        'inline; filename="Admin-Assistant-Resume.pdf"'})
    end
    def stub_cruncher_job_create
      stub_request(:post, CruncherService.service_url + '/job/create').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_job_create_fail(resultCode)
      stub_request(:post, CruncherService.service_url + '/job/create').
          to_return(body: "{\"resultCode\":\"#{resultCode}\"}" , status: 200,
          :headers => {'Content-Type' => 'application/json'})
    end
    def stub_cruncher_job_create_error
      stub_request(:post, CruncherService.service_url + '/job/create').
          to_raise(RuntimeError)
    end

    def stub_cruncher_match_jobs

      body_json = JSON.generate({"resultCode"=>"SUCCESS", "message"=>"Success",
              "jobs"=>{"matcher1"=>[{"jobId"=>"2", "stars"=>3.8},
                                    {"jobId"=>"3", "stars"=>4.7},
                                    {"jobId"=>"6", "stars"=>3.2}],
                       "matcher2"=>[{"jobId"=>"8", "stars"=>2.8},
                                    {"jobId"=>"9", "stars"=>2.9},
                                    {"jobId"=>"6", "stars"=>3.4}]}})

      stub_request(:get, CruncherService.service_url + '/job/match/1').
        to_return(body: body_json, status:200,
        headers: {'Content-Type': 'application/json'})
    end

    def stub_cruncher_match_jobs_fail(resultCode)
      stub_request(:get, CruncherService.service_url + '/job/match/1').
        to_return(body: "{\"resultCode\": \"#{resultCode}\"}", status:200,
        headers: {'Content-Type': 'application/json'})
    end

    def stub_cruncher_match_resumes
      body_json = JSON.generate({"resultCode"=>"SUCCESS", "message"=>"Success",
           "resumes"=>{"matcher1"=>[{"resumeId"=>"2", "stars"=>2.0},
                                    {"resumeId"=>"7", "stars"=>4.9},
                                    {"resumeId"=>"5", "stars"=>3.6}],
                       "matcher2"=>[{"resumeId"=>"8", "stars"=>1.8},
                                    {"resumeId"=>"5", "stars"=>3.8},
                                    {"resumeId"=>"6", "stars"=>1.7}]}})

      stub_request(:get, CruncherService.service_url + '/resume/match/1').
          to_return(body: body_json, status: 200,
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
          /^#{EmailValidateService.service_url}\/validate?.*/).
          to_return(body: body_json)
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
          /^#{EmailValidateService.service_url}\/validate?.*/).
          to_return(body: body_json)
    end

    def stub_email_validate_error
      stub_request(:get,
          /^#{EmailValidateService.service_url}\/validate?.*/).
          to_raise(RuntimeError)
    end
  end

end
