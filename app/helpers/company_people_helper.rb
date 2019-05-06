module CompanyPeopleHelper
  def disable_company_admin?(company_person, role)
    # Disable the check_box for the company admin role if this person
    # is the sole admin for the company (return true to disable).

    return false unless role == CompanyRole::ROLE[:CA]

    company_person.sole_company_admin?
  end
end
