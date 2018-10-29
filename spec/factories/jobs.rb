FactoryBot.define do
  factory :job do
    title 'MyString'
    description 'MyString'
    company
    company_person { FactoryBot.create(:company_person, company: company) }
    address
    company_job_id 'KRKE12'
    status :active
    available_positions 1
    remaining_positions 1
  end
end
