FactoryGirl.define do
  factory :job_seeker do
  	email 'johndoe@place.com'
    first_name 'John'
    last_name "Doe"
    phone '(123) 123 1234'
    year_of_birth "1998"
    resume "MyString"
  end

end
