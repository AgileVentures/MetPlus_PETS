class CompanyRegistrationPolicy < ApplicationPolicy
  def show?
    agency_admin?(user, record) || company_admin?(user, record)
  end

  def edit?
    update?
  end

  def update?
    agency_admin?(user, record)
  end

  def destroy?
    update?
  end

  def approve?
    update?
  end

  def deny?
    update?
  end

  private

  def company_admin?(user, record)
    user.is_a?(CompanyPerson) && user.company_admin?(record.company)
  end

  def agency_admin?(user, record)
    User.agency_admin?(user) &&
      (agency_admin_related_to_company? user, record.company)
  end

  def agency_admin_related_to_company?(admin, company)
    admin.agency.companies.include? company
  end
end
