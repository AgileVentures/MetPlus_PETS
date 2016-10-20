class EmailValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)

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
      # Fall back to format check if service not available
      unless value =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
        object.errors[attribute] << (options[:message] || 'is not formatted properly')
      end
    end
  end
end
