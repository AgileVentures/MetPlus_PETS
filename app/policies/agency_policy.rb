class AgencyPolicy < ApplicationPolicy
  def update?
    record ? user.agency_admin?(record) : false
  end

  def update_job_properties?
    access = user.job_developer?(record) || user.agency_admin?(record)
    record ? access : false
  end
end
