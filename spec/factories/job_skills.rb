FactoryGirl.define do
  factory :job_skill do
    job
    skill
    skill_level nil
    required false
    min_years 1
    max_years 1
  end
end
