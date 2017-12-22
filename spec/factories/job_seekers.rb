FactoryBot.define do
  factory :job_seeker do
    year_of_birth '1998'
    job_seeker_status
    association :address, factory: :address
    user
  end
  factory :job_seeker_applicant, class: JobSeeker do
    year_of_birth '1998'
    job_seeker_status
    association :address, factory: :address
    association :user, factory: :user_applicant
  end
end
