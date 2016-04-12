require 'rails_helper'
require 'agency_mailer'

RSpec.describe Event, type: :model do
  let!(:agency)    { FactoryGirl.create(:agency) }
  let(:job_seeker) { FactoryGirl.create(:job_seeker) }
  let(:company)    { FactoryGirl.create(:company, agencies: [agency]) }

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
end
