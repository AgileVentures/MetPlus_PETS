class EinNumberValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    reg = /^\d{2}\-?\d{7}$/
    unless value.match reg
      object.errors[attribute] << (options[:message] || 'incorrect format')
    end
    if value.gsub('-', '').to_i == 0
      object.errors[attribute] << (options[:message] || 'invalid number')
    end
  end
end