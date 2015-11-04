require 'rails_helper'

RSpec.describe Company, type: :model do

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:company)).to be_valid
    end
  end
   
  describe 'Associations' do
    it { is_expected.to have_many :company_people }
    it { is_expected.to have_many :addresses }
    it { is_expected.to have_many :jobs }
    it {is_expected.to have_and_belong_to_many :agencies }
   end

   describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :ein }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :website }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of :ein }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :website }
    it { is_expected.to validate_length_of(:website).is_at_most(200) }
  end

end


  
  
  
  
