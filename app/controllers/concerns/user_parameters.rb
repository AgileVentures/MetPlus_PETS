module UserParameters
  extend ActiveSupport::Concern

  def handle_user_form_parameters(parameters)
    if parameters[:password].nil? || parameters[:password].to_s.empty?
      parameters.delete(:password)
      parameters.delete(:password_confirmation)
    end

    parameters
  end
end
