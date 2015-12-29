FactoryGirl.define do
  factory :company_person do
    company
    address
    user
    status CompanyPerson::STATUS[:ACT]
  end

end
