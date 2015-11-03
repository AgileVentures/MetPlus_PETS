FactoryGirl.define do
  factory :company_person do
    company 
    address 
    first_name 'John'
    last_name "Doe"
	phone '(123) 123 1234'
    company_roles "Case Manager"
  end

end
