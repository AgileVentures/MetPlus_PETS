class JobCategoryPolicy < ApplicationPolicy
  def create?
    User.agency_admin? user
  end

  def show?
    User.agency_admin? user
  end

  def update?
    User.agency_admin? user
  end

  def destroy?
    User.agency_admin? user
  end
end
