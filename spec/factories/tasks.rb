FactoryBot.define do
  factory :task do
    task_type 'new_task'
    association :owner, factory: :job_seeker, strategy: :build
    owner_agency_role ''
    owner_company_role ''
    deferred_date '2016-03-29 15:37:07'
    status Task::STATUS[:NEW]
  end
end
