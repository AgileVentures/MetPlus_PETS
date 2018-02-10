require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Skill, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.create(:skill)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:job_skills) }
    it { is_expected.to have_many(:jobs).through(:job_skills).dependent(:destroy) }
    it { is_expected.to belong_to(:organization) }
    describe 'dependent: :destroy' do
      let(:job_skill) do
        FactoryBot.create(:job_skill,
                          job: FactoryBot.create(:job),
                          skill: FactoryBot.create(:skill))
      end
      it 'destroys jobs with join association when skill is destroyed' do
        jobs = job_skill.skill.jobs
        expect { job_skill.skill.destroy }.to \
          change { jobs.count }.from(1).to(0).and \
            change { JobSkill.count }.by(-1)
      end
    end
  end

  describe 'Validations' do
    subject { FactoryBot.build(:skill) }

    describe 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
    describe 'Description' do
      it { is_expected.to validate_presence_of :description }
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :jobs_count }
    it { is_expected.to have_db_column :organization_id }
    it { is_expected.to have_db_column :organization_type }
  end

  describe 'has_job?' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    let(:skill) { FactoryBot.create(:skill) }
    let(:job)   { FactoryBot.create(:job) }

    it 'returns false without a job' do
      expect(skill.has_job?).to be false
    end

    it 'returns true with a job' do
      FactoryBot.create(:job_skill, job: job, skill: skill)
      expect(skill.has_job?).to be true
    end
  end

  describe 'counter_cache' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'increments jobs_count when a new row is created in job_skill table' do
      waiter = FactoryBot.create(:job)
      phone_operator = FactoryBot.create(:job)
      speak_english = FactoryBot.create(:skill)
      JobSkill.create(job: waiter, skill: speak_english, min_years: 0, max_years: 10)
      JobSkill.create(job: phone_operator, skill: speak_english, min_years: 0,
                      max_years: 10)
      expect(speak_english.jobs_count).to eql 2
      expect(speak_english.jobs_count).to eql speak_english.jobs.count
    end
  end
end
