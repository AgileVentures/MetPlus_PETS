require 'rails_helper'

RSpec.describe User, type: :model do
  
   describe 'Fixtures' do
      it 'should have a valid factory' do
        expect(FactoryGirl.create(:user)).to be_valid
   end
  end
   
   describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :email}
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :actable_id }
    it { is_expected.to have_db_column :actable_type }
  end
    
  describe 'Validations' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name  }
    it 'validates correct phone  format' do
      
      expect(FactoryGirl.build(:user, phone: '123-456-7890')).to be_valid
      expect(FactoryGirl.build(:user, phone: '12345')).to_not be_valid
      expect(FactoryGirl.build(:user, phone: '123-3455')).to_not be_valid
      
    end
  end
  
  describe 'Class methods' do
  end
  
  describe 'Instance methods' do
  end


end



