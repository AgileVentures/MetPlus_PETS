class YearOfBirthValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.nil?

    reg = /\A\d{4}\z/

    if !value =~ reg || !(100.years.ago.year..Date.today.year - 16).member?(value.to_i)
      object.errors[attribute] << (options[:message] ||
        'age need to be between 16 and 100')
    end
  end
end
