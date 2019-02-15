class EmailValidator < ActiveModel::EachValidator
  def self.use_mailgun?
    ENV['MAILGUN_EMAIL_VALIDATION'] == 'yes'
  end

  def validate_each(object, attribute, value)
    if EmailValidator.use_mailgun?
      valid_check = EmailValidateService.validate_email(value)
      if valid_check[:status] == 'SUCCESS'

        return if valid_check[:valid]

        if valid_check[:did_you_mean].nil?
          object.errors[attribute] << (options[:message] || 'is not a valid address')
        else
          object.errors[attribute] <<
            "is not valid (did you mean ... #{valid_check[:did_you_mean]}?)"
        end

      else
        # Fall back to format checkif service is unavailable
        check_email_format(object, attribute, value)
      end

    else
      check_email_format(object, attribute, value)
    end
  end

  def check_email_format(object, attribute, value)
    unless value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      object.errors[attribute] << (options[:message] || 'is not formatted properly')
    end
  end
end
