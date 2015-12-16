require 'rails_helper'

RSpec.describe AgencyPerson, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency_person)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to :branch }
    it { is_expected.to have_and_belong_to_many :agency_roles }
    it { is_expected.to have_and_belong_to_many(:job_categories).
            join_table('job_specialities')}
    it { is_expected.to have_and_belong_to_many(:job_seekers).
            join_table('seekers_agency_people') }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :agency_id }
    it { is_expected.to have_db_column :branch_id }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :agency_id }
    it 'invalidates removing admin role for sole agency admin' do
      person = FactoryGirl.create(:agency_person)
      role = AgencyRole.create(role: AgencyRole::ROLE[:AA])
      person.agency_roles << role
      expect(person).to be_valid
      person.agency_roles.delete(role)
      person.save
      expect(person).to_not be_valid
    end
  end

  describe 'Agency Person' do
    it 'is valid with all required fields' do
      expect(AgencyPerson.new(agency_id: 1, 
          email: 'agencyperson2@gmail.com', first_name: 'Agency', 
          last_name: 'Person', password: 'qwerty123')).to be_valid
    end
    it 'is invalid without an agency association' do
      agency = AgencyPerson.new()
      agency.valid?
      expect(agency.errors[:agency_id]).to include("can't be blank")
    end
  end
  
  describe 'Agency Admin checks' do
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
    
    it 'confirms sole agency admin' do
      expect(aa_person.sole_agency_admin?).to be true
    end
    it 'confirms not sole agency admin if not admin' do
      expect(jd_person.sole_agency_admin?).to be false
    end
    it 'confirms not sole agency admin if another admin' do
      expect(aa_person2.sole_agency_admin?).to be false
    end
    
  end

end
