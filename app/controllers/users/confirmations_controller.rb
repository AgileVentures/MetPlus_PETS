class Users::ConfirmationsController < Devise::ConfirmationsController
  require 'pusher_manager'
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
      # If email is confirmed and user is a job seeker, send event
      if user.errors.empty? && user.actable_type == 'JobSeeker'
        person = user.actable
        PusherManager.trigger_event(:JS_REGISTER,
                name: person.full_name(last_name_first: false))
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
