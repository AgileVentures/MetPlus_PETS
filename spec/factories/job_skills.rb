FactoryBot.define do
  factory :job_skill do
    job
    skill
    required false
    min_years 1
    max_years 1
  end
end
