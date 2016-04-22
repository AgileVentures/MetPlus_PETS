require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'Fixtures' do
    xit 'should have a valid factory' do
      expect(FactoryGirl.build(:job)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :company_person }
    it  { is_expected.to belong_to :address }
    it { is_expected.to belong_to :job_category }
    it { is_expected.to have_many :job_skills }
    it { is_expected.to have_many(:skills).through(:job_skills) }
    it { is_expected.to have_many(:required_skills).through(:job_skills).
          conditions(job_skills: {required: true}).
          source(:skill).class_name('Skill') }
    it { is_expected.to have_many(:nice_to_have_skills).
          through(:job_skills).conditions(job_skills: {required: false}).
          source(:skill).class_name('Skill')}
    it { is_expected.to have_many(:skill_levels).through(:job_skills) }
    it { is_expected.to have_many(:job_applications) }
    it { is_expected.to have_many(:job_seekers).through(:job_applications) }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :title }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :company_job_id }
    it { is_expected.to have_db_column :shift}
    it { is_expected.to have_db_column :fulltime}
    it { is_expected.to have_db_column :company_id }

    it { is_expected.to have_db_column :company_person_id }
    it { is_expected.to have_db_column :address_id }
    xit { is_expected.to have_db_column :job_category_id }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_length_of(:description).is_at_most(10000) }
    it { is_expected.to validate_presence_of :company_job_id }
    it { should allow_value('', nil).for(:fulltime).on(:update) }
    it { should allow_value('', nil).for(:fulltime).on(:create) }
    it { is_expected.to validate_presence_of :company_id }
    xit { is_expected.to validate_presence_of :company_person_id }
    xit { is_expected.to validate_presence_of :job_category_id }
    it{ is_expected.to validate_inclusion_of(:shift).in_array(%w[Day Evening Morning])} 
  end
  
  describe 'Class methods' do
  end
  
  describe 'Instance methods' do
  end
end
