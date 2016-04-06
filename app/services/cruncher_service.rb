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

  def self.upload_file(file, file_name, user_id)
    mime_type = MIME::Types.type_for(file_name)

    raise "Invalid MIME type for file: #{file_name}" if mime_type.empty?
    raise "Unsupported file type of file: #{file_name}" if
          not Resume::FILETYPES.include? mime_type.first.preferred_extension

    result = RestClient.post(service_url + '/curriculum/upload',
      { 'file'   => file,
        'name'   => file_name,
        'userId' => user_id },
      { 'Accept' => 'application/json',
        'X-Auth-Token' => auth_token,
        'Content-Type' => mime_type.first.content_type })

    result_code = JSON.parse(result)['resultCode']
    message     = JSON.parse(result)['message']

    return true if result_code == 'SUCCESS'
    false
  end

  private

  def self.auth_token
    return @@auth_token if @@auth_token

    result = RestClient.post(service_url + '/authenticate', {},
                {'X-Auth-Username' => ENV['CRUNCHER_SERVICE_USERNAME'],
                 'X-Auth-Password' => ENV['CRUNCHER_SERVICE_PASSWORD']})
    @@auth_token =  JSON.parse(result)['token']
  end

end
