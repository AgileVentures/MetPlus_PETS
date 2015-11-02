require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:job)).to be_valid
    end
  end
  
  describe 'Associations' do
    xit { is_expected.to belong_to :company }
    xit { is_expected.to belong_to :company_person }
     it  { is_expected.to have_one  :address }
    xit { is_expected.to belong_to :job_category }
<<<<<<< HEAD
     it {is_expected.to have_many :job_skills }
     it { is_expected.to have_many(:skills).through(:job_skills)}
    xit { is_expected.to have_many(:required_skills).
          through(:job_skills).condition(required: true).
          source(:skill).class_name('Skill')}
    xit { is_expected.to have_many(:nice_to_have_skills).
          through(:job_skills).condition(required: false).
=======
    it { is_expected.to have_many :job_skills }
    it { is_expected.to have_many(:skills).through(:job_skills) }
    it { is_expected.to have_many(:required_skills).through(:job_skills).
          conditions(job_skills: {required: true}).
          source(:skill).class_name('Skill') }
    it { is_expected.to have_many(:nice_to_have_skills).
          through(:job_skills).conditions(job_skills: {required: false}).
>>>>>>> development
          source(:skill).class_name('Skill')}
    xit { is_expected.to have_many(:skill_levels).through(:job_skills) }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :title }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :company_person_id }
    it { is_expected.to have_db_column :job_category_id }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_length_of(:description).is_at_most(10000) }
    it { is_expected.to validate_presence_of :company_id }
    it { is_expected.to validate_presence_of :company_person_id }
    it { is_expected.to validate_presence_of :job_category_id }
  end
  
  describe 'Class methods' do
  end
  
  describe 'Instance methods' do
  end
end
