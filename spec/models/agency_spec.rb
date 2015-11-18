require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to have_many :agency_people }
    it { is_expected.to have_many :addresses }
    it { is_expected.to have_and_belong_to_many :companies }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :website }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :fax }
    it { is_expected.to have_db_column :description }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of :website }
    it { is_expected.to validate_length_of(:website).is_at_most(200) }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :email }
  end
  
  describe 'Agency' do
    it 'is valid with all required fields' do
      expect(Agency.new(name: 'Agency', website: 'myurl.com',
                        phone: '000-123-4567', email: 'agency@mail.com')).to be_valid
    end
    it 'is invalid without a name, website, phone or email' do
      agency = Agency.new()
      agency.valid?
      expect(agency.errors[:name]).to include("can't be blank")
      expect(agency.errors[:website]).to include("can't be blank")
      expect(agency.errors[:phone]).to include("can't be blank")
      expect(agency.errors[:email]).to include("can't be blank")
    end
    
  end
end
