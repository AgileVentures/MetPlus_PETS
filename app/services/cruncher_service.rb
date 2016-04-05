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

  private

  def self.auth_token
    @@auth_token = @@auth_token ||
    Rest.Client.post('service_url' + '/authenticate', {},
                {'X-Auth-Username' => ENV['CRUNCHER_SERVICE_USERNAME'],
                 'X-Auth-Password' => ENV['CRUNCHER_SERVICE_PASSWORD']})
  end


end
