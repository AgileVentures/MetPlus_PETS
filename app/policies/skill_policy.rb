class SkillPolicy < ApplicationPolicy
  def create?
    User.agency_admin?(user) || User.company_person?(user)
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
