class CompanyPolicy < ApplicationPolicy
  def update?
    user.is_agency_admin? record.agency
  end
  
  def destroy?
    update?
  end


end



