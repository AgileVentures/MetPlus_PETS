FactoryGirl.define do
  factory :company_person do
    company
    address
    user
    title "Manager"
    status CompanyPerson::STATUS[:ACT]
  end

  factory :company_admin, class: CompanyPerson do
    company
    address
    user
    title "Admin"
    company_roles {[CompanyRole.find_by_role(CompanyRole::ROLE[:CA]) || FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])]}
  end

  factory :company_contact, class: CompanyPerson do
    company
    address
    user
    title "Contact"
    company_roles {[CompanyRole.find_by_role(CompanyRole::ROLE[:CC]) || FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])]}
  end

end
