require 'rails_helper'

RSpec.describe AgencyRole, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency_role)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many :agency_people }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :role }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :role }
    it { is_expected.to validate_length_of(:role).is_at_most(40) }
  end

  describe 'Agency Role' do
    it 'is valid with all required fields' do
      expect(AgencyRole.new(role: 'JobDeveloper')).to be_valid
    end
    it 'is invalid without an agency role' do
      agency_role = AgencyRole.new()
      agency_role.valid?
      expect(agency_role.errors[:role]).to include("can't be blank")
    end
  end
end
