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
      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_file_upload_retry_auth
      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_raise(RestClient::Unauthorized).then.
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end
    def stub_cruncher_file_upload_error
      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_raise(RuntimeError)
    end
    def stub_cruncher_file_download(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, /#{CruncherService.service_url + "/curriculum/"}\d+/).
          to_return(body: file.read, status: 200,
          :headers => {'Content-Disposition'=>
                        'inline; filename="Admin-Assistant-Resume.pdf"'})
    end
    def stub_cruncher_file_download_notfound
      stub_request(:get, CruncherService.service_url + '/curriculum/2').
          to_return(body: "{\"resultCode\":\"RESUME_NOT_FOUND\",
                            \"message\":\"Unable to find the user '2'\"}",
                    status: 200)
    end
    def stub_cruncher_file_download_retry_auth(testfile)
      file = fixture_file_upload(testfile)

      stub_request(:get, CruncherService.service_url + '/curriculum/1').
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
      stub_request(:get, CruncherService.service_url + '/job/match/1').
        to_return(body: "{\"resultCode\": \"SUCCESS\", \"jobs\":\"{}\"}", status:200,
        headers: {'Content-Type': 'application/json'})
    end
    def stub_cruncher_match_jobs_fail(resultCode)
      stub_request(:get, CruncherService.service_url + '/job/match/1').
        to_return(body: "{\"resultCode\": \"#{resultCode}\"}", status:200,
        headers: {'Content-Type': 'application/json'})
    end

    def stub_cruncher_match_resumes
      stub_request(:get, CruncherService.service_url + '/curriculum/match/1').
          to_return(body: "{ \"resultCode\":\"SUCCESS\", \"resumes\":{}}", status: 200,
          headers: { 'Content-Type': 'application/json' })
    end

  end

end
