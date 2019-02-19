class WebsiteValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /^((https?:\/\/)([\da-z\.-]+)|([\da-z\.-]+))\.([a-z\.]{2,6})(([\/\w \.-]|:\d+)*)*\/?$/i
      object.errors[attribute] << (options[:message] || 'is not a valid website address')
    end
  end
end
