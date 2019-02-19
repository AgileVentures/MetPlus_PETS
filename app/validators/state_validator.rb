class StateValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless Address.states_small_name.include? value
      object.errors[attribute] << (options[:message] || 'not present in the list of states')
    end
  end
end
