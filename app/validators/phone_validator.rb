class PhoneValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value == nil
    reg = /^(\+\d{1,3} )?\(?\d{3}\)?( |-)?\d{3}( |-)?\d{4}$/
    unless value.match reg
      object.errors[attribute] << (options[:message] || 'incorrect format')
    end
  end
end