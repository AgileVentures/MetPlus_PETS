require 'rails_helper'

RSpec.describe SkillLevel, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:skill_level)).to be_valid
    end
  end
  
  describe 'Associations' do
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end
  
  describe 'Skill Level' do
    it 'is valid with all required fields' do
      expect(SkillLevel.new(name: 'Beginner', 
              description: 'Entry level or minimal experience')).to be_valid
    end
    it 'is invalid without a name or description' do
      skill_level = SkillLevel.new()
      skill_level.valid?
      expect(skill_level.errors[:name]).to include("can't be blank")
      expect(skill_level.errors[:description]).to include("can't be blank")
    end
  end
end
