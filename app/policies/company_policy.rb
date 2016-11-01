# CompanyPolicy authorization
class CompanyPolicy < ApplicationPolicy
  def edit?
    user.is_agency_admin?(record.agency) || user.is_company_admin?(record)
  end

  def update?
    edit?
  end

  def destroy?
    user.is_agency_admin? record.agency
  end

  def show?
    user.is_agency_admin?(record.agency) || user.is_company_admin?(record)
  end

  def list_people?
    user.is_agency_admin?(record.agency) || user.is_company_person?(record)
  end
end
