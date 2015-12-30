FactoryGirl.define do
  factory :agency_person do
    agency
    branch
    user
    status AgencyPerson::STATUS[:ACT]
  end

end
