require 'rails_helper'

RSpec.describe Event, type: :model do

  describe 'js_registered event' do
    it 'triggers a Pusher message' do
      allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
      Event.create(:JS_REGISTER, name: 'Sam Smith', id: 1)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'js_registered',
                         {name: 'Sam Smith', id: 1})
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
  end
end
