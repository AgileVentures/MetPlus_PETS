module UserParameters
	extend ActiveSupport::Concern

	def handle_user_form_parameters parameters

		if parameters[:password].nil? or parameters[:password].to_s.length == 0
			parameters.delete(:password)
			parameters.delete(:password_confirmation)
		end

		parameters
	end
end
