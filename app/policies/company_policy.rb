class CompanyPolicy < ApplicationPolicy
  def edit?
    user.is_agency_admin? record.agency or user.is_company_admin? record.agency
  end
  
  def update?
    edit?
  end

  def destroy?
    user.is_agency_admin? record.agency
  end

  def show?
    user.is_agency_admin? record.agency or user.is_company_admin? record.agency
  end
 
  def list_people?
    user.is_agency_admin? record.agency or user.is_company_person?
  end
end

