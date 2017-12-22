FactoryBot.define do
  factory :job_application do
    job_seeker nil
    job
    status :active
  end

  factory :not_accepted_job_application, class: JobApplication do
    job_seeker nil
    job
    status :not_accepted
  end

  factory :processing_job_application do
    job_seeker nil
    job
    status :processing
  end
end
