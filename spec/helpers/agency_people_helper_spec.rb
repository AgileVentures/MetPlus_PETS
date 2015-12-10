require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the AgencyPeopleHelper. For example:
#
# describe AgencyPeopleHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AgencyPeopleHelper, type: :helper do
  context 'disable agency admin check_box' do
    let(:agency) { FactoryGirl.create(:agency) }
    let!(:aa_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let(:aa_person2)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let(:jd_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:JD])
      $person.save
      $person
    end
      
    it 'returns true for sole agency admin' do
      expect(disable_agency_admin?(aa_person, AgencyRole::ROLE[:AA])).to be true
    end
    
    it 'returns false for non-admin' do
      expect(disable_agency_admin?(jd_person, AgencyRole::ROLE[:AA])).to be false
    end
    
    it 'returns false when more than one admin' do
      expect(disable_agency_admin?(aa_person2, AgencyRole::ROLE[:AA])).to be false
    end
    
  end
end
