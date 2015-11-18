module AgencyAdminHelper
  def current_user_agency_admin
    return false unless user_signed_in?
    return false unless ((person = current_user.actable).is_a? AgencyPerson)
    person.agency_roles.each do |ar|
      return true if ar.role == AgencyRole::ROLE[:AA]
    end
    false
  end
end
