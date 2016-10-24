class EmailValidateService
  require 'rest-client'
  require 'json'

  @@url = nil

  def self.service_url
    return @@url if @@url
    @@url = "https://api:#{MAILGUN_PUBLIC_KEY}@#{EMAIL_VALIDATE_URL}/address"
  end

  def self.validate_email(email_address)
    return {status: 'SUCCESS',
            valid: false,
            did_you_mean: nil} if email_address.nil? or email_address.empty?

    begin
      validate_url = self.service_url + '/validate?' +
                                        "address=#{CGI::escape(email_address)}"

      result = JSON.parse(RestClient.get(validate_url))
      return {status: 'SUCCESS',
              valid: result['is_valid'],
              did_you_mean: result['did_you_mean']}
    rescue
      return {status: 'ERROR'}
    end
  end
end
