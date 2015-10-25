FactoryGirl.define do
  factory :job do
    title "MyString"
    description "MyString"
    company_id 1
    company_person_id 1
    address
    job_category_id 1
  end
  
  # replace the id's for 'belongs_to' associations above with actual factory references
  # as the associated models are defined (company, company_person, job_category)

end
