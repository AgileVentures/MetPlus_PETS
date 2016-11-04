class CompanyPersonPolicy < ApplicationPolicy
  
  def update?
    (agency_admin? user and agency_related_to_company?(user.agency, record.company)) or
      user.is_company_admin? record.company
  end
  
  def edit?
    update?
  end
  
  def destroy?
    update?
  end
  
  def show?
    (agency_person? user and agency_related_to_company?(user.agency, record.company)) or
      user.is_company_admin? record.company
  end
  
  def home?
    (agency_admin? user and agency_related_to_company?(user.agency, record.company)) or
      user.is_company_person? record.company
  end
  
  def update_profile?
    user.is_company_person? record.company and user == record
  end
  
  def edit_profile?
    update_profile?
  end

  private

    def agency_person? user
      User.is_agency_person? user
    end

    def agency_admin? user
      User.is_agency_admin? user
    end

    def agency_related_to_company? agency, company
      company.agencies.include? agency
    end

end