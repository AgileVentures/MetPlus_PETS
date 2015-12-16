class PeopleInvitationsController < Devise::InvitationsController
  def new
    session[:person_type] = params[:person_type]
    session[:agency_id]   = params[:agency_id]
    super
  end

  def edit
  end

  def update
  end
  
  private
  
	# this is called when creating invitation
  # should return an instance of resource class (User)
	def invite_resource(&block)
		user = resource_class.invite!(invite_params, current_inviter, &block)
		if user.errors.empty?
      case session[:person_type]
      when 'AgencyPerson'
				agency_person = AgencyPerson.new 
        agency_person.user = user
        agency_person.agency_id = session[:agency_id]
				agency_person.status = AgencyPerson::STATUS[:IVT]
				agency_person.save
        store_location_for user, edit_agency_person_path(agency_person.id)
			end
      session[:person_type] = nil
      session[:agency_id]   = nil
		end
		user
	end
  
=begin
  def after_invite_path_for(user_inviter)
    debugger
    case user.actable
    when AgencyPerson
      edit_agency_person_path(user.actable.id)
    when CompanyPerson
      company_admin_home_path(user.actable.id)
    else
      super
    end
  end
=end
end
