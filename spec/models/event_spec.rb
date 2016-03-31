require 'rails_helper'
require 'agency_mailer'

RSpec.describe Event, type: :model do
  Delayed::Worker.delay_jobs = false
  
  let!(:agency) { FactoryGirl.create(:agency) }

  before(:each) do
    3.times do |n|
      FactoryGirl.create(:agency_person, agency: agency)
    end
  end

  describe 'js_registered event' do
    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:JS_REGISTER, name: 'Sam Smith', id: 1)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'js_registered',
                         {name: 'Sam Smith', id: 1})
    end

    it 'sends event notification email' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:JS_REGISTER, name: 'Sam Smith', id: 1) }.
                    to change(all_emails, :count).by(+1)
    end

  end

  describe 'company_registered event' do
    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:COMP_REGISTER, name: 'Widgets, Inc.', id: 1)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'company_registered',
                         {name: 'Widgets, Inc.', id: 1})
    end

    it 'sends event notification email' do
      allow(Pusher).to receive(:trigger)
      expect { Event.create(:COMP_REGISTER, name: 'Widgets, Inc.', id: 1) }.
                    to change(all_emails, :count).by(+1)
    end

  end
end
