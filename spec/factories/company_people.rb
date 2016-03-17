FactoryGirl.define do
  factory :company_person do
    company
    address
    user
    title "Manager"
    status CompanyPerson::STATUS[:ACT]
  end

end
