FactoryGirl.define do
  sequence :email do |n|
      "unique#{n}@gmail.com"
  end
  
  factory :user do
	  first_name 'John'
	  last_name "Doe"
	  phone '(123) 123 1234'
    email
    password 'qwerty123'
  end

end
