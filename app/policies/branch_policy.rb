# BranchPolicy
class BranchPolicy < ApplicationPolicy
  def new?
    user.agency_admin? record.agency
  end

  def create?
    user.agency_admin? record.agency
  end

  def edit?
    user.agency_admin? record.agency
  end

  def update?
    user.agency_admin? record.agency
  end

  def destroy?
    update?
  end

  def show?
    user.agency_person? record.agency
  end
end
