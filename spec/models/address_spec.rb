require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
    end
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :location }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :street }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :zipcode }
    it { is_expected.to have_db_column :location_id }
    it { is_expected.to have_db_column :location_type }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :street }
    it { is_expected.to validate_presence_of :city }
    it 'validates correct zip code format' do
      expect(FactoryGirl.build(:address, zipcode: '33445')).to be_valid
      expect(FactoryGirl.build(:address, zipcode: '55555-4444')).to be_valid
      expect(FactoryGirl.build(:address, zipcode: '666666')).to_not be_valid
      expect(FactoryGirl.build(:address, zipcode: '12345-22')).to_not be_valid
      expect(FactoryGirl.build(:address, zipcode: '123456789')).to_not be_valid
      expect(FactoryGirl.build(:address, zipcode: 'abcde')).to_not be_valid
    end
  end
  
  describe 'Class methods' do
  end
  
  describe 'Instance methods' do
  end
  
end
