class CruncherService
  require 'rest-client'
  require 'json'

  @@auth_token = nil

  def self.service_url=(url) # called from initializer
    @@service_url = url
  end

  def self.service_url
    @@service_url
  end

  def self.upload_file(file, file_name, file_id)
    mime_type = MIME::Types.type_for(URI.escape(file_name))

    raise "Invalid MIME type for file: #{file_name}" if mime_type.empty?
    raise "Unsupported file type for: #{file_name}" if
          not Resume::FILETYPES.include? mime_type.first.preferred_extension

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
