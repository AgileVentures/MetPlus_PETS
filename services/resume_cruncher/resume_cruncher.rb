require 'rest-client'
class ResumeCruncher
  def initialize
    cruncher = PETS_CONFIG['cruncher']
    @site = RestClient::Resource.new(url_constructor, :verify_ssl => cruncher['verify_ssl'])
  end
  private
  def url_constructor
    cruncher = PETS_CONFIG['cruncher']
    url = 'http'
    url += 's' if cruncher['ssl']
    url += '://'
    url += cruncher['user']
    url += ':'
    url += cruncher['password']
    url + "@#{cruncher['host']}:#{cruncher['port']}/"
  end
end