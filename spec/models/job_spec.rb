require 'rails_helper'

RSpec.describe Job, type: :model do
  before(:all) {
    @company = FactoryGirl.create(:company)
    @employer = FactoryGirl.create(:employer, :company => @company)
    FactoryGirl.create(:skill, :name => 'Software developer')
    FactoryGirl.create(:skill, :name => 'Handyman')
    FactoryGirl.create(:skill, :name => 'English Teacher')
    FactoryGirl.create(:skill, :name => 'Dean')
  }
  after(:all) {
    DatabaseCleaner.clean_with(:truncation)
  }
  describe 'Check model restrictions' do
    subject { FactoryGirl.build(:job) }
    describe 'Employer' do
      it { should validate_presence_of(:employer)}
      it { should belong_to(:employer)}
    end
    describe 'Company' do
      it { should validate_presence_of(:company) }
      it { should belong_to(:company)}
    end
    describe 'Title' do
      it {should validate_presence_of(:title) }
      it {should validate_length_of(:title)}
    end
    describe 'Description' do
      it {should validate_presence_of(:description) }
      it {should validate_length_of(:description)}
    end
  end
  describe 'Job creation' do
    subject { FactoryGirl.build(:job) }
    describe 'Check skills' do
      it 'Check required skills' do
        subject.required_skills << Skill.find_by_name('Handyman')
        subject.nice_to_have_skills << Skill.find_by_name('Dean')
        subject.save
        subject = Job.all.first

        expect(subject.required_skills.first).to eq(Skill.find_by_name 'Handyman')
        expect(subject.nice_to_have_skills.first).to eq(Skill.find_by_name 'Dean')
      end
    end
  end
end
