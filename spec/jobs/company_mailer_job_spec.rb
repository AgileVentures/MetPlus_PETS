require 'rails_helper'

RSpec.describe CompanyMailerJob, type: :job do
  let!(:company)        { FactoryGirl.create(:company) }
  let(:company_person)  { FactoryGirl.create(:company_person,
                                    company: company)}
  let!(:job_seeker) { FactoryGirl.create(:job_seeker) }
  let(:job_application) { FactoryGirl.create(:job_application,
                                    job_seeker: job_seeker,
                                    job: FactoryGirl.create(:job)) }
  let(:resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }

  before(:each) do
    Delayed::Worker.delay_jobs = true
  end

  after(:each) do
    Delayed::Worker.delay_jobs = false
  end

  it 'company registered event' do
    expect { CompanyMailerJob.set(wait: Event.delay_seconds.seconds).
                              perform_later(Event::EVT_TYPE[:COMP_REGISTER],
                              company,
                              company_person) }.
    to change(Delayed::Job, :count).by (+1)

  end

  it 'company registration approved event' do
    expect { CompanyMailerJob.set(wait: Event.delay_seconds.seconds).
                              perform_later(Event::EVT_TYPE[:COMP_APPROVED],
                              company,
                              company_person) }.
    to change(Delayed::Job, :count).by (+1)
  end

  it 'company registration denied event' do
    obj = Struct.new(:company, :reason).new
    obj.company = company
    obj.reason = 'We are unable to accept new partners at this time'
    expect { CompanyMailerJob.set(wait: Event.delay_seconds.seconds).
                              perform_later(Event::EVT_TYPE[:COMP_DENIED],
                              company,
                              company_person,
                              obj.reason) }.
    to change(Delayed::Job, :count).by (+1)
  end

  it 'job application receieved event' do
    resume_file_path = File.new("#{Rails.root}/spec/fixtures/files/#{resume.file_name}").path
    expect { CompanyMailerJob.set(wait: Event.delay_seconds.seconds).
                              perform_later(Event::EVT_TYPE[:JS_APPLY],
                              company, nil, nil,
                              job_application,
                              resume_file_path) }.
    to change(Delayed::Job, :count).by (+1)
  end
end
