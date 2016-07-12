class FaxValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value == nil
    reg = /^(1-)?((\(\d{3}\))|\d{3})( |-)?\d{3}( |-)?\d{4}( ?x\d+)?$/
    unless value.match reg
      object.errors[attribute] << (options[:message] || 'Invalid format')
    end
  end
end