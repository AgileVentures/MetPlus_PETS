class PeopleInvitationsController < Devise::InvitationsController
  def new
    session[:person_type] = params[:person_type]
    session[:org_id]      = params[:org_id]
    super
  end
  
  private
  
	# this is called when creating invitation
  # should return an instance of resource class (User)
	def invite_resource(&block)
		user = resource_class.invite!(invite_params, current_inviter, &block)
		if user.errors.empty?
      case session[:person_type]
      when 'AgencyPerson'
				person = AgencyPerson.new 
        person.user = user
        person.agency_id = session[:org_id]
				person.status = AgencyPerson::STATUS[:IVT]
				person.save
        store_location_for user, edit_agency_person_path(person.id)
      when 'CompanyPerson'
        # logic here
      end 
      session[:person_type] = nil
      session[:org_id]      = nil
    else
      @model_errors = user.errors
		end
		user
	end
  
  # this is called when accepting invitation
  # should return an instance of resource class (User)
  def accept_resource
    user = resource_class.accept_invitation!(update_resource_params)
    case (person = user.actable)
    when AgencyPerson
      person.status = AgencyPerson::STATUS[:ACT]
      person.save
      store_location_for user, agency_home_path(person.agency_id)
    when CompanyPerson
      # logic here
    end
    user
  end

end
