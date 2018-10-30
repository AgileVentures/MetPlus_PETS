class AgencyPolicy < ApplicationPolicy
  def update?
    record ? user.agency_admin?(record) : false
  end
  def update_job_properties?
    record ? user.job_developer?(record) : false
  end
end
