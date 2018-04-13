class AgencyPolicy < ApplicationPolicy
  def update?
    record ? user.agency_admin?(record) : false
  end
end
