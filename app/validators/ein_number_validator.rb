class EinNumberValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if !value || value.empty?
      object.errors[attribute] << (options[:message] || 'is missing')
    elsif value.gsub('-', '').to_i == 0
      object.errors[attribute] << (options[:message] || 'is not a valid number')
    elsif not value.match /^\d{2}\-?\d{7}$/
      object.errors[attribute] << (options[:message] || 'has incorrect format')
    end
  end
end
