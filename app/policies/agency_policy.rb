class AgencyPolicy < ApplicationPolicy
  def update?
    record ? user.is_agency_admin?(record) : false
  end
end
