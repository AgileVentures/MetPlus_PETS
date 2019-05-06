class Users::ConfirmationsController < Devise::ConfirmationsController
  require 'event'
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super do |user|
      if user.errors.empty? && user.actable_type == 'JobSeeker'
        person = user.actable
        Event.create(:JS_REGISTER, person)
      else
        # Override normal handling if the user's email address has already been
        # confirmed.  In that case, clear the error messages and the parent
        # method will redirect to login (with appropriate flash message)
        # (this error will happen if the user clicks the link in the
        #  comnfirmation email more than once)
        user.errors.clear if user.errors.messages[:email] &&
                             (user.errors.messages[:email][0] ==
                               t("errors.messages.already_confirmed"))
      end
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
