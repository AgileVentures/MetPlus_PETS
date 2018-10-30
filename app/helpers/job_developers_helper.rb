module JobDevelopersHelper
  def current_user_job_developer?
    return false unless user_signed_in?
    return false unless ((person = current_user.actable).is_a? AgencyPerson)
    person.agency_roles.pluck(:role).include? AgencyRole::ROLE[:JD]    
  end
end
