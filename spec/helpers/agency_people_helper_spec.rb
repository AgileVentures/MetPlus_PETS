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

  context 'job_seeker / agency_person relationships' do
    let(:agency) { FactoryGirl.create(:agency) }

    let!(:aa_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA]) }
    let!(:jd_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD]) }
    let!(:cm_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM]) }

    let!(:aa_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << aa_role
      $person.save
      $person
    end
    let!(:cm_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << cm_role
      $person.save
      $person
    end
    let!(:jd_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << jd_role
      $person.save
      $person
    end
    let!(:adam)    { FactoryGirl.create(:job_seeker, first_name: 'Adam', last_name: 'Smith') }
    let!(:bob)     { FactoryGirl.create(:job_seeker, first_name: 'Bob', last_name: 'Smith') }
    let!(:charles) { FactoryGirl.create(:job_seeker, first_name: 'Charles', last_name: 'Smith') }
    let!(:dave)    { FactoryGirl.create(:job_seeker, first_name: 'Dave', last_name: 'Smith') }

    before(:each) do
      cm_person.agency_relations << AgencyRelation.new(agency_role: cm_role,
                                          job_seeker: adam)
      cm_person.save!
      jd_person.agency_relations << AgencyRelation.new(agency_role: jd_role,
                                          job_seeker: dave)
      jd_person.save!
    end
    it 'returns job seekers for job developer role' do
      expect(eligible_job_seekers_for_role(cm_person, :JD)).
                          to match_array [adam, bob, charles]

      expect(eligible_job_seekers_for_role(jd_person, :JD)).
                          to match_array [adam, bob, charles, dave]
    end
    it 'returns job seekers for case manager role' do
      expect(eligible_job_seekers_for_role(cm_person, :CM)).
                          to match_array [adam, bob, dave, charles]

      expect(eligible_job_seekers_for_role(jd_person, :CM)).
                          to match_array [bob, charles, dave]
    end

  end
end
