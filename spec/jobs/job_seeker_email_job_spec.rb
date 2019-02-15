require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobSeekerEmailJob, type: :job do
  let(:agency)        { FactoryBot.create(:agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryBot.create(:job_seeker) }
  let(:job)           { FactoryBot.create(:job) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'job developer assigned to job seeker event' do
    expect do
      JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds)
                       .perform_later(Event::EVT_TYPE[:JD_ASSIGNED_JS],
                                      job_seeker, job_developer)
    end
      .to have_enqueued_job(JobSeekerEmailJob)
  end

  it 'case manager assigned to job seeker event' do
    expect do
      JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds)
                       .perform_later(Event::EVT_TYPE[:CM_ASSIGNED_JS],
                                      job_seeker, case_manager)
    end
      .to have_enqueued_job(JobSeekerEmailJob)
  end

  before do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  it 'job applied by job developer event' do
    expect do
      JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds)
                       .perform_later(Event::EVT_TYPE[:JD_APPLY],
                                      job_seeker, job_developer, job)
    end
      .to have_enqueued_job(JobSeekerEmailJob)
  end
end
