require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobSeekerEmailJob, type: :job do

  let(:agency)        { FactoryGirl.create(:agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryGirl.create(:job_seeker) }
  let(:job)           { FactoryGirl.create(:job) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'job developer assigned to job seeker event' do
    expect{ JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Event::EVT_TYPE[:JD_ASSIGNED_JS],
                 job_seeker, job_developer) }.
      to change(Delayed::Job, :count).by(+1)
  end

  it 'case manager assigned to job seeker event' do
    expect{ JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Event::EVT_TYPE[:CM_ASSIGNED_JS],
                 job_seeker, case_manager) }.
      to change(Delayed::Job, :count).by(+1)
  end

  before do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  it 'job applied by job developer event' do
    expect{ JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Event::EVT_TYPE[:JD_APPLY],
                 job_seeker, job_developer, job) }.
      to change(Delayed::Job, :count).by(+1)
  end

end
