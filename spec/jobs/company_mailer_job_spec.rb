require 'rails_helper'

include ServiceStubHelpers::Cruncher

RSpec.describe CompanyMailerJob, type: :job do
  let!(:company)        { FactoryBot.create(:company) }
  let(:company_person)  do
    FactoryBot.create(:company_person,
                      company: company)
  end
  let!(:job_seeker) { FactoryBot.create(:job_seeker) }
  let(:job_application) do
    FactoryBot.create(:job_application,
                      job_seeker: job_seeker,
                      job: FactoryBot.create(:job))
  end
  let(:resume) { FactoryBot.create(:resume, job_seeker: job_seeker) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'company registered event' do
    expect do
      CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                      .perform_later(Event::EVT_TYPE[:COMP_REGISTER],
                                     company,
                                     company_person)
    end
      .to have_enqueued_job(CompanyMailerJob)
  end

  it 'company registration approved event' do
    expect do
      CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                      .perform_later(Event::EVT_TYPE[:COMP_APPROVED],
                                     company,
                                     company_person)
    end
      .to have_enqueued_job(CompanyMailerJob)
  end

  it 'company registration denied event' do
    obj = Struct.new(:company, :reason).new
    obj.company = company
    obj.reason = 'We are unable to accept new partners at this time'
    expect do
      CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                      .perform_later(Event::EVT_TYPE[:COMP_DENIED],
                                     company,
                                     company_person,
                                     reason: obj.reason)
    end
      .to have_enqueued_job(CompanyMailerJob)
  end

  it 'job application received event' do
    stub_cruncher_authenticate
    stub_cruncher_job_create
    stub_cruncher_file_upload

    resume_file_path = File.new("#{Rails.root}/spec/fixtures/files/#{resume.file_name}")
                           .path
    expect do
      CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                      .perform_later(Event::EVT_TYPE[:JS_APPLY],
                                     company, nil,
                                     application: job_application,
                                     resume_file_path: resume_file_path)
    end
      .to have_enqueued_job(CompanyMailerJob)
  end
end
