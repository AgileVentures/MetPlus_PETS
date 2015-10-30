require 'rails_helper'

RSpec.describe AgencyPerson, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency_person)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to :address }
    xit { is_expected.to have_and_belong_to_many :agency_roles }
    xit { is_expected.to have_and_belong_to_many :job_specialities }
    xit { is_expected.to have_many(:job_categories).
      through(:job_specialities) }
    xit { is_expected.to have_and_belong_to_many(:job_seekers).
      through(:seekers_agency_people) }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :agency_id }
    it { is_expected.to have_db_column :address_id }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :agency_id }
  end
  
  describe 'Agency Person' do
    it 'is valid with all required fields' do
      expect(AgencyPerson.new(agency_id: 1)).to be_valid
    end
    it 'is invalid without an agency association' do
      agency = AgencyPerson.new()
      agency.valid?
      expect(agency.errors[:agency_id]).to include("can't be blank")
    end
  end
end
