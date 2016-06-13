require 'rails_helper'

RSpec.describe NotifyEmailJob, type: :job do

  let(:agency) { FactoryGirl.create(:agency) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
    3.times do
      FactoryGirl.create(:agency_person, agency: agency)
    end
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'job seeker registered event' do
    expect{ NotifyEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Agency.all_agency_people_emails,
                 Event::EVT_TYPE[:JS_REGISTER],
                 {name: 'Joe Newseeker', id: 1}) }.
      to change(Delayed::Job, :count).by(+1)
  end

  it 'company registered event' do
    expect{ NotifyEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Agency.all_agency_people_emails,
                 Event::EVT_TYPE[:COMP_REGISTER],
                 {name: 'Newco', id: 1}) }.
      to change(Delayed::Job, :count).by(+1)
  end

  it 'job seeker applied to job event' do
    expect{ NotifyEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Agency.all_agency_people_emails,
                 Event::EVT_TYPE[:JS_APPLY],
                 {name: 'Joe Newseeker', id: 1}) }.
      to change(Delayed::Job, :count).by(+1)
  end

  it 'job seeker assigned to job developer event' do
    expect{ NotifyEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later('job_developer@gmail.com',
                 Event::EVT_TYPE[:JS_ASSIGN_JD],
                 {name: 'Joe Newseeker', id: 1}) }.
      to change(Delayed::Job, :count).by(+1)
  end

end
