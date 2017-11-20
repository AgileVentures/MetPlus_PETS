class LicensePolicy < ApplicationPolicy
  def create?
    User.is_agency_admin?(user) || User.is_company_person?(user)
  end
  def show?
    create?
  end
  def update?
    create?
  end
  def destroy?
    create?
  end
end
