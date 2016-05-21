require 'rails_helper'
require 'agency_mailer'

RSpec.describe Event, type: :model do
  let!(:agency)        { FactoryGirl.create(:agency) }
  let(:job_seeker)     { FactoryGirl.create(:job_seeker) }
  let(:agency_admin)   { FactoryGirl.create(:agency_admin) }
  let(:company)        { FactoryGirl.create(:company, agencies: [agency]) }
  let(:company_person) { FactoryGirl.create(:company_person, company: company) }
  let(:job)            { FactoryGirl.create(:job, company: company,
                                            company_person: company_person) }
  let(:application) do
    job.apply job_seeker
    job.last_application_by_job_seeker(job_seeker)
  end

  before(:each) do
    3.times do |n|
      FactoryGirl.create(:agency_person, agency: agency)
    end
  end

  describe 'js_registered event' do
    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:JS_REGISTER, job_seeker)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'js_registered',
                         {name: job_seeker.full_name(last_name_first: false),
                          id: job_seeker.id})
    end

    it 'sends event notification email' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:JS_REGISTER, job_seeker) }.
                    to change(all_emails, :count).by(+1)
    end

    it 'creates two tasks' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:JS_REGISTER, job_seeker) }.
                    to change(Task, :count).by(+2)
    end
  end

  describe 'company_registered event' do
    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:COMP_REGISTER, company)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'company_registered',
                         {name: company.name, id: company.id})
    end

    it 'sends event notification email' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:COMP_REGISTER, company) }.
                    to change(all_emails, :count).by(+1)
    end

    it 'creates one task' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:COMP_REGISTER, company) }.
                    to change(Task, :count).by(+1)
    end
  end

  describe 'jobseeker_applied event' do

    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:JS_APPLY, application)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'jobseeker_applied',
                         {job_id:  job.id,
                          js_id:   job_seeker.id,
                          js_name: job_seeker.full_name(last_name_first: false),
                          notify_list: [company_person.user.id]})
    end

    it 'sends event notification email' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:JS_APPLY, application) }.
                    to change(all_emails, :count).by(+1)
    end

    it 'creates one task' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:JS_APPLY, application) }.
                    to change(Task, :count).by(+1)
    end
  end
end
