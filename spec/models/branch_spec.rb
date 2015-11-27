require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:branch)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to :address }
    it { is_expected.to have_many :agency_people }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :agency_id }
    it { is_expected.to have_db_column :address_id }
    it { is_expected.to have_db_column :code }
  end
end
