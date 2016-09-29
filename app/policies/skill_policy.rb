class SkillPolicy < ApplicationPolicy
  def create?
    not User.is_agency_admin? user
  end
  def show?
    not User.is_agency_admin? user
  end
  def update?
    not User.is_agency_admin? user
  end
  def destroy?
    not User.is_agency_admin? user
  end
end
