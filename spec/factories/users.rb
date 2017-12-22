FactoryBot.define do
  sequence :email do |n|
    "unique#{n}@gmail.com"
  end
  factory :user do
    first_name 'John'
    last_name 'Doe'
    phone '(123) 123 1234'
    email
    password 'qwerty123'
    password_confirmation 'qwerty123'
    confirmed_at Time.now
  end
  factory :user_applicant, class: User do
    first_name 'John'
    last_name 'Doe'
    phone '(123) 123 1234'
    email
    password 'qwerty123'
    password_confirmation 'qwerty123'
  end
end
