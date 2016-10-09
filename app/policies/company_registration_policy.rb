class CompanyRegistrationPolicy < ApplicationPolicy

  def show?
    agency_admin? user, record or company_admin? user, record
  end

  def update?
    agency_admin? user, record
  end

  private

  def company_admin? user, record
    user.is_a? CompanyPerson and user.is_company_admin? record.company
  end

  def agency_admin? user, record
    User.is_agency_admin? user and (agency_admin_related_to_company? user, record.company)
  end

  def agency_admin_related_to_company? admin, company
    admin.agency.companies.include? company
  end
  
end