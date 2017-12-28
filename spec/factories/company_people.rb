FactoryBot.define do
  factory :company_person do
    company
    address
    user
    title 'Manager'
    status 'active'
  end

  factory :first_company_admin, class: CompanyPerson do
    company
    address
    user
    title 'Admin'
    status 'active'
    company_roles do
      [CompanyRole.find_by_role(CompanyRole::ROLE[:CC]) ||
        FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC]),
       CompanyRole.find_by_role(CompanyRole::ROLE[:CA]) ||
         FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])]
    end
  end

  factory :pending_first_company_admin, class: CompanyPerson do
    company
    address
    user
    title 'Admin'
    status 'company_pending'
    approved false
    company_roles do
      [CompanyRole.find_by_role(CompanyRole::ROLE[:CC]) ||
        FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC]),
       CompanyRole.find_by_role(CompanyRole::ROLE[:CA]) ||
         FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])]
    end
  end

  factory :company_admin, class: CompanyPerson do
    company
    address
    user
    title 'Admin'
    status 'active'
    company_roles do
      [CompanyRole.find_by_role(CompanyRole::ROLE[:CA]) ||
        FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])]
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
        FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC])]
    end
  end
end
