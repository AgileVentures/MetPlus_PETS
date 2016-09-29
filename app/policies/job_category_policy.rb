class JobCategoryPolicy < ApplicationPolicy
  def create?
    not user.nil? and User.is_agency_admin? user
  end
  def show?
    not user.nil? and User.is_agency_admin? user
  end
  def update?
    not user.nil? and User.is_agency_admin? user
  end
  def destroy?
    not user.nil? and User.is_agency_admin? user
  end
end
