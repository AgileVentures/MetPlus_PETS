FactoryGirl.define do
  factory :job do
    title "MyString"
    description "MyString"
    company_id 1
    company_person_id 1
    address
    job_category_id 1
    jobId "KRKE12"
    shift 'day'
    fulltime true 
  end
  
end
