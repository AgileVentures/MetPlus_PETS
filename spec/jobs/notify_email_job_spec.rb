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

  it 'adds email to job queue' do
    expect{ NotifyEmailJob.set(wait: Event.delay_seconds.seconds).
                 perform_later(Agency.all_agency_people_emails,
                 Event::EVT_TYPE[:JS_REGISTER],
                 {name: 'Joe Newseeker', id: 1}) }.
      to change(Delayed::Job, :count).by(+1)
  end

end
