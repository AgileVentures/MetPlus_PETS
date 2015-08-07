class StateValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless Address.states_small_name.include? value
      object.errors[attribute] << (options[:message] || 'state is incorrect')
    end
  end
end