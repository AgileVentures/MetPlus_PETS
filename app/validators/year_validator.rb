class YearValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value == nil
    reg = /\A\d{4}\z/
    
    if !value.match reg && !((value.to_i<=Date.today.year)&&( value.to_i>=(Date.today.year - 100)))
        object.errors[attribute] << (options[:message] || 'incorrect format')
    end
end
