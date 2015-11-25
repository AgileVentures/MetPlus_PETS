require 'rails_helper'

RSpec.describe AgencyAdminHelper, type: :helper do
  context 'person_full_name(person)' do
    it 'returns full name of person' do
      agency_person = FactoryGirl.build(:agency_person)
      expect(person_full_name(agency_person)).
          to eq "#{agency_person.first_name} #{agency_person.last_name}"
    end
  end
end
