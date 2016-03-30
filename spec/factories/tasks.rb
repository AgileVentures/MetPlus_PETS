FactoryGirl.define do
  factory :task do
    type ""
    association :owner, factory: :job_seeker
    owner_agency_role ""
    owner_company_role ""
    deferred_date "2016-03-29 15:37:07"
  end

end
