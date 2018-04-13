# CompanyPolicy implementation
class CompanyPolicy < ApplicationPolicy
  def edit?
    company_admin?(user, record) || agency_admin?(user, record)
  end

  def update?
    edit?
  end

  def destroy?
    agency_admin?(user, record)
  end

  def show?
    edit?
  end

  def list_people?
    agency_admin?(user, record) || user.company_person?(record)
  end

  private

  def company_admin?(user, record)
    user.is_a?(CompanyPerson) && user.company_admin?(record)
  end

  def agency_admin?(user, record)
    User.agency_admin?(user) && (agency_admin_related_to_company? user, record)
  end

  def agency_admin_related_to_company?(admin, company)
    admin.agency.companies.include? company
  end
end
