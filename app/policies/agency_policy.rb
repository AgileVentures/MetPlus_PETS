class AgencyPolicy < ApplicationPolicy
  def create?
    user.is_agency_admin? record
  end
  def update?
    user.is_agency_admin? record
  end
  def destroy?
    user.is_agency_admin? record
  end
end