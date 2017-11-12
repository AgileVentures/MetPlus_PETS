class LicensePolicy < ApplicationPolicy
  def create?
    User.is_agency_admin? user
  end
  def show?
    User.is_agency_admin? user
  end
  def update?
    User.is_agency_admin? user
  end
  def destroy?
    User.is_agency_admin? user
  end
end
