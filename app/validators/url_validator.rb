class UrlValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})(([\/\w \.-]|:\d+)*)*\/?$/i
      object.errors[attribute] << (options[:message] || 'is not an url')
    end
  end
end
