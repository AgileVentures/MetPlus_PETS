FactoryGirl.define do
  factory :job_seeker do
    year_of_birth "1998"
    resume "MyString"
    job_seeker_status_id "Employedlooking"
    user
  end
end
