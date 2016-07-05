require 'rails_helper'

RSpec.describe JobSeekerEmailJob, type: :job do

  let(:agency)        { FactoryGirl.create(:agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'job developer assigned to job seeker event' do
    expect{ JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Event::EVT_TYPE[:JS_ASSIGN_JD],
                 job_seeker, job_developer) }.
      to change(Delayed::Job, :count).by(+1)
  end

  it 'case manager assigned to job seeker event' do
    expect{ JobSeekerEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Event::EVT_TYPE[:JS_ASSIGN_CM],
                 job_seeker, case_manager) }.
      to change(Delayed::Job, :count).by(+1)
  end

end
