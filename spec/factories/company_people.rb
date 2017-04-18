FactoryGirl.define do
  factory :company_person do
    company
    address
    user
    title 'Manager'
    status 'active'
  end

  factory :company_admin, class: CompanyPerson do
    company
    address
    user
    title 'Admin'
    status 'active'
    company_roles do
      [CompanyRole.find_by_role(CompanyRole::ROLE[:CC]) ||
        FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC]),
        CompanyRole.find_by_role(CompanyRole::ROLE[:CA]) ||
        FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])]
    end
  end

  factory :company_contact, class: CompanyPerson do
    company
    address
    user
    title 'Contact'
    status 'active'
    company_roles do
      [CompanyRole.find_by_role(CompanyRole::ROLE[:CC]) ||
        FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])]
    end
  end
end
