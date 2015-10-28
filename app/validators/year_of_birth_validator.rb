class YearOfBirthValidator < ActiveModel::EachValidator

  def validate_each(object, attribute, value)
    return if value == nil
    reg = /\A\d{4}\z/
    if !value=~reg  || !((1915..2015).member?(value.to_i))
        object.errors[attribute] << (options[:message] || 'incorrect format')
    end
  end
end
