FactoryGirl.define do
  factory :job_application do
    job_seeker nil
    job
    status :active
  end

end
