require 'rest-client'
require 'json'

class RecaptchaService
  # Ref: https://developers.google.com/recaptcha/docs/verify
  def self.verify(captcha_response, ip_address)
    return false if !captcha_response || captcha_response.empty?

    result = request(captcha_response, ip_address)
    JSON.parse(result)['success']
  end

  def self.request(captcha_response, ip_address)
    RestClient::Request.execute(
      method: :post,
      url: recaptcha_url,
      verify_ssl: false,
      headers: {
        params: {
          secret: ENV['RECAPTCHA_PRIVATE_KEY'],
          response: captcha_response,
          remoteip: ip_address
        }
      }
    )
  end

  def self.recaptcha_url
    'https://www.google.com/recaptcha/api/siteverify'
  end
end
