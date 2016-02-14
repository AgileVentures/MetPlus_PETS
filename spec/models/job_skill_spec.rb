require 'rails_helper'

RSpec.describe JobSkill, type: :model do
  describe 'Fixtures' do
    xit 'should have a valid factory' do
      expect(FactoryGirl.create(:job_skill)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :skill }
    it { is_expected.to belong_to :skill_level }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :job_id }
    it { is_expected.to have_db_column :skill_id }
    it { is_expected.to have_db_column :skill_level_id }
    it { is_expected.to have_db_column :required }
    it { is_expected.to have_db_column :min_years }
    it { is_expected.to have_db_column :max_years }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :job }
    it { is_expected.to validate_presence_of :skill }
    it { is_expected.to validate_inclusion_of(:required).
              in_array([true, false]) }
    it { is_expected.to validate_numericality_of(:min_years).
            is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:min_years).
            is_less_than_or_equal_to(15) }
    it { is_expected.to validate_numericality_of(:max_years).
            is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:max_years).
            is_less_than_or_equal_to(50) }
  end
  
  describe 'Job Skill' do
    xit 'is valid with all required fields' do
      job = FactoryGirl.create(:job)
      skill = FactoryGirl.create(:skill)
      expect(JobSkill.new(job: job, skill: skill,
            min_years: 0, max_years: 10)).to be_valid
    end
    it 'is invalid without a job_id, skill_id or valid years' do
      job_skill = JobSkill.new()
      job_skill.valid?
      expect(job_skill.errors[:job]).to include("can't be blank")
      expect(job_skill.errors[:skill]).to include("can't be blank")
      expect(job_skill.errors[:min_years]).to include("is not a number")
      expect(job_skill.errors[:max_years]).to include("is not a number")
    end
  end

end
