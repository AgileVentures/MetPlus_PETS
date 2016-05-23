FactoryGirl.define do
  factory :job do
    title "MyString"
    description "MyString"
    company
    company_person
    address
    # job_category_id 1
    company_job_id "KRKE12"
    shift 'Day'
    fulltime true
  end

end
