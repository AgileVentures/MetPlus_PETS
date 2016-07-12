FactoryGirl.define do
  factory :job do
    title "MyString"
    description "MyString"
    company
    company_person {FactoryGirl.create(:company_person, company: company)}
    address
    company_job_id "KRKE12"
    shift 'Day'
    fulltime true
    status Job::STATUS[:ACTIVE]
  end

end
