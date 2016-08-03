require 'rails_helper'

RSpec.describe CompanyMailerJob, type: :job do
  let!(:company)        { FactoryGirl.create(:company) }
  let(:company_person)  { FactoryGirl.create(:company_person,
                                    company: company)}

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
end
