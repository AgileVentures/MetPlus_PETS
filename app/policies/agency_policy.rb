class AgencyPolicy < ApplicationPolicy
  def update?
    user.is_agency_admin? record
  end
end
