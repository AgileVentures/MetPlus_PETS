class PeopleInvitationsController < Devise::InvitationsController
  def new
    session[:person_type] = params[:person_type]
    session[:org_id]      = params[:org_id]

    self.resource = resource_class.new
    case params[:person_type]
    when 'AgencyPerson'
      @agency_name = Agency.find(params[:org_id]).name
      render :new_agency_person
    when 'CompanyPerson'
      @company_name = Company.find(params[:org_id]).name
      render :new_company_person
    end
  end

  private

  # this is called when creating or resending an invitation
  # should return an instance of resource class (User)
  def invite_resource(&block)
    user = resource_class.invite!(invite_params, current_inviter, &block)
    if user.errors.empty?
      if (person = user.actable)
        # If a person is already associated with this user, this means that
        # another invitation is being sent to that previously-invited person.
        redirect_path = (person.class == AgencyPerson ?
                  agency_person_path(person.id) : company_person_path(person.id))
        store_location_for user, redirect_path
      else
        # Otherwise, this is a first invitation for this user - associate a person
        case session[:person_type]
        when 'AgencyPerson'
          person = AgencyPerson.new
          person.user = user
          person.agency_id = session[:org_id]
          person.invited
          person.save
          store_location_for user, edit_agency_person_path(person.id)
        when 'CompanyPerson'
          person = CompanyPerson.new
          person.user = user
          person.company_id = session[:org_id]
          person.invited
          person.save
          store_location_for user, edit_company_person_path(person.id)
        end
      end
      session[:person_type] = nil
      session[:org_id]      = nil
    end
    user
  end

  # this is called when accepting invitation
  # should return an instance of resource class (User)
  def accept_resource
    user = resource_class.accept_invitation!(update_resource_params)
    case (person = user.actable)
    when AgencyPerson
      person.active
      person.save
      store_location_for user, agency_home_path(person.agency_id)
    when CompanyPerson
      person.active
      person.save
      store_location_for user, company_home_path(person.company_id)
    end
    user
  end

  protected

  def after_invite_path_for(resource)
    stored_location_for(resource) || request.referer || root_path
  end
end
