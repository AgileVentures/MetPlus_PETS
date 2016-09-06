class CruncherService
  require 'rest-client'
  require 'json'

  @@auth_token = nil

  def self.service_url
    # Changed to use constant instead of class var as Rails reloads all
    # classes on each request (unless config.cache_classes = true)
    CRUNCHER_URL
  end

  def self.upload_file(file, file_name, file_id)
    mime_type = MIME::Types.type_for(URI.escape(file_name))

    raise "Invalid MIME type for file: #{file_name}" if mime_type.empty?
    raise "Unsupported file type for: #{file_name}" if
          not Resume::MIMETYPES.include? mime_type.first.content_type

    retry_upload = true
    begin
      result = RestClient.post(service_url + '/curriculum/upload',
              { 'file'   => file,
                'name'   => file_name,
                'userId' => file_id },
              { 'Accept' => 'application/json',
                'X-Auth-Token' => auth_token,
                'Content-Type' => mime_type.first.content_type })

      return JSON.parse(result)['resultCode'] == 'SUCCESS'

    rescue RestClient::Unauthorized   # most likely expired token
      # Retry and force refresh of cached auth_token
      self.auth_token = nil
      if retry_upload
        retry_upload = false
        file = file.open # reopen as .post closes the file
        retry
      end
      raise
    end
  end


  def self.download_file(file_id)
    # Download the contents of the file which was stored in the Cruncher
    # using the file_id (e.g. resume.id).
    # Save the contents to a Tempfile, and close file.
    # Return the Tempfile instance if successful, nil otherwise.

    retry_download = true
    begin
      # Successful call returns RestClient::Response instance.
      # That quacks like a string but also contains other info, see:
      # https://github.com/rest-client/rest-client#result-handling

      contents = RestClient.get(service_url + "/curriculum/#{file_id}",
                              'X-Auth-Token' => auth_token)

      # If successful, :content_disposition will be set in the header
      return nil unless contents.headers[:content_disposition]

      tempfile = Tempfile.new("file_id_#{file_id}_", './tmp')
      tempfile.write contents
      tempfile.close

      return tempfile

    rescue RestClient::Unauthorized   # most likely expired token
      # Retry and force refresh of cached auth_token
      self.auth_token = nil
      if retry_download
        retry_download = false
        retry
      end
      raise
    end
  end


  def self.create_job(jobId, title, description)

    retry_create = true
    begin
      result = RestClient.post(service_url + '/job/create',
              { 'jobId'   => jobId,
                'title'   => title,
                'description' => description },
              { 'Accept' => 'application/json',
                'X-Auth-Token' => auth_token })

      return JSON.parse(result)['resultCode'] == 'SUCCESS'

    rescue RestClient::Unauthorized   # most likely expired token
      # Retry and force refresh of cached auth_token
      self.auth_token = nil
      if retry_create
         retry_create = false
         retry
      end
      raise
    end


  end

  def self.match_jobs(resume_id)

    # Define retry_search to true outside the begin block
    # otherwise retry_search would be set to true everytime
    # we retry the block. Can also set it inside the begin block
    # like retry_search ||= true so that its set only the first
    # time

    retry_search = true

    begin
      result = RestClient.get(service_url + '/job/match/' + resume_id.to_s,
                              { 'X-Auth-Token': auth_token })

      result_hash = JSON.parse(result)

      # Set matching jobs to nil if resume couldn't be found
      matching_jobs = nil

      if result_hash['resultCode'] == 'SUCCESS'
        # May or may not contain jobs matching the resume
        matching_jobs = result_hash['jobs']

        #convert job ids returned by the matcher into ints
        matching_jobs.transform_values! { |arr| arr.map(&:to_i) }

      end
    rescue RestClient::Unauthorized
      self.auth_token = nil
      if retry_search
        retry_search = false
        retry
      end
      raise
    end
    matching_jobs
  end


  def self.match_resumes(job_id)

    retry_match = true

    begin
      result = RestClient.get(service_url + '/curriculum/match/' + job_id.to_s,
                { 'Accept': 'application/json',
                  'X-Auth-Token': auth_token })
      matching_resumes = JSON.parse(result)['resumes']

      # convert the resume ids to integers
      matching_resumes.transform_values! { |arr| arr.map(&:to_i) }

    rescue RestClient::Unauthorized
      if retry_match
        self.auth_token = nil
        retry_match = false
        retry
      end
      raise
    end

    matching_resumes

  end


  def self.auth_token
    return @@auth_token if @@auth_token

    result = RestClient.post(service_url + '/authenticate', {},
                {'X-Auth-Username' => ENV['CRUNCHER_SERVICE_USERNAME'],
                 'X-Auth-Password' => ENV['CRUNCHER_SERVICE_PASSWORD']})

    raise "Invalid credentials for Cruncher access" if result.code == 401

    self.auth_token =  JSON.parse(result)['token']
  end

  def self.auth_token=(token)
    @@auth_token =  token
  end

end
