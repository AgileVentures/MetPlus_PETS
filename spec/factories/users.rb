

FactoryGirl.define do
<<<<<<< HEAD
	sequence :email do |n|
		"unique#{n}@gmail.com"

	end
=======
  sequence :email do |n|
      "unique#{n}@gmail.com"
  end
  
  factory :user do
	  first_name 'John'
	  last_name "Doe"
	  phone '(123) 123 1234'
    email
    password 'qwerty123'
    password_confirmation 'qwerty123'
    confirmed_at Time.now
  end
>>>>>>> development

	factory :user do
		password 'MyString1233'
		password_confirmation 'MyString1233'
		first_name 'John'
		last_name "Doe"
		email 
		phone '(123) 123 1234'
		confirmed_at Date.today
	end
end
