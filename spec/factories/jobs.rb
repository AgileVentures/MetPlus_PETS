FactoryGirl.define do
  factory :job do
    title "MyString"
    description "MyString"
    company
    company_person {FactoryGirl.create(:company_person, company: company)}
    address
    company_job_id "KRKE12"
    status :active
  end

end
