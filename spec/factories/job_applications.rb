FactoryGirl.define do
  factory :job_application do
    job_seeker nil
    job
    status :active
    reason_for_rejection 'Skill do not Match'
  end
end
