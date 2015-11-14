FactoryGirl.define do
  factory :user do
	password 'MyString1233'
	password_confirmation 'MyString1233'
	first_name 'John'
	last_name "Doe"
	email 'johndoe@place.com'
	phone '(123) 123 1234'
	confirmed_at Date.today

  end

end
