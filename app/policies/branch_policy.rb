class BranchPolicy < ApplicationPolicy
  def new?
    user.is_agency_admin? record.agency
  end
  
  def create?
    user.is_agency_admin? record.agency
  end

  def edit?
    user.is_agency_admin? record.agency
  end
 
  def update?
    user.is_agency_admin? record.agency
  end
  
  def destroy?
    update?
  end

  def show?
    user.is_agency_person? record.agency
  end

end 

