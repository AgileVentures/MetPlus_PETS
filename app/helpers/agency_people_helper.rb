module AgencyPeopleHelper
  def disable_agency_admin?(agency_person, role)
    
    # Disable the check_box for the agency admin role if this person
    # is the sole admin for the agency (return true to disable).
    
    return false unless role == AgencyRole::ROLE[:AA]
    agency_person.sole_agency_admin?
  end
end
