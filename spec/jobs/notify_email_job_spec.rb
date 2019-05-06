require 'rails_helper'

RSpec.describe NotifyEmailJob, type: :job do
  let(:agency) { FactoryBot.create(:agency) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
    3.times do
      FactoryBot.create(:agency_person, agency: agency)
    end
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'job seeker registered event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later(Agency.all_agency_people_emails,
                                   Event::EVT_TYPE[:JS_REGISTER],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'company registered event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later(Agency.all_agency_people_emails,
                                   Event::EVT_TYPE[:COMP_REGISTER],
                                   name: 'Newco', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job seeker applied to job event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later(Agency.all_agency_people_emails,
                                   Event::EVT_TYPE[:JS_APPLY],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job application accepted event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:APP_ACCEPTED],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job application rejected event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:APP_REJECTED],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job seeker assigned to job developer event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:JD_ASSIGNED_JS],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job seeker assigned to case manager event' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('case_manager@gmail.com',
                                   Event::EVT_TYPE[:CM_ASSIGNED_JS],
                                   name: 'Joe Newseeker', id: 1)
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'new job posted' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:JOB_POSTED],
                                   job: { title: 'test job' },
                                   agency: { name: 'MetPlus' })
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'job revoked' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:JOB_REVOKED],
                                   job: { title: 'test job' },
                                   agency: { name: 'MetPlus' })
    end
      .to have_enqueued_job(NotifyEmailJob)
  end

  it 'company interest in job seeker' do
    expect do
      NotifyEmailJob.set(wait: Event.delay_seconds.seconds)
                    .perform_later('job_developer@gmail.com',
                                   Event::EVT_TYPE[:CP_INTEREST_IN_JS],
                                   job: { title: 'test job' },
                                   company_person: { last_name: 'Jobs' },
                                   job_seeker: { last_name: 'Seeker' })
    end
      .to have_enqueued_job(NotifyEmailJob)
  end
end
