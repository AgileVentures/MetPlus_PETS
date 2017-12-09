require 'rails_helper'

describe CompanyRole, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:company_role)).to be_valid
    end
  end

  describe 'Associations' do
    it {
      is_expected.to have_and_belong_to_many(:company_people)
        .join_table('company_people_roles')
    }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :role }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :role }
    it { is_expected.to validate_length_of(:role).is_at_most(40) }
    it { is_expected.to validate_inclusion_of(:role).in_array(CompanyRole::ROLE.values) }
  end

  describe 'Company Role' do
    it 'is valid with all required fields' do
      expect(CompanyRole.new(role: CompanyRole::ROLE[:CC])).to be_valid
    end
    it 'is invalid without an agency role' do
      agency_role = AgencyRole.new
      agency_role.valid?
      expect(agency_role.errors[:role]).to include("can't be blank")
    end
  end

  FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC])
  FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])

  describe CompanyRole.select(:role).map(&:role) do
    it { should include(CompanyRole::ROLE[:CC], CompanyRole::ROLE[:CA]) }
  end
end
