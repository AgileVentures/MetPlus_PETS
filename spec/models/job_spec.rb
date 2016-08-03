require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Job, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:job)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :company_person }
    it { is_expected.to belong_to :address }
    it { is_expected.to belong_to :job_category }
    it { is_expected.to have_many(:job_skills).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:job_skills).
                              allow_destroy(true) }
    it { is_expected.to have_many(:skills).through(:job_skills) }
    it { is_expected.to have_many(:required_skills).through(:job_skills).
          conditions(job_skills: {required: true}).
          source(:skill).class_name('Skill') }
    it { is_expected.to have_many(:nice_to_have_skills).
          through(:job_skills).conditions(job_skills: {required: false}).
          source(:skill).class_name('Skill')}
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
    it { is_expected.to have_db_column :status }
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
    it { is_expected.to validate_inclusion_of(:shift).
                                      in_array(%w[Day Evening Morning]) }
    it { is_expected.to validate_inclusion_of(:status).
                                      in_array(Job::STATUS.values) }
  end

  describe 'Class methods' do
  end

  describe 'Instance methods' do
    describe '#apply' do
      let(:job) {FactoryGirl.create(:job)}
      let(:job_seeker) {FactoryGirl.create(:job_seeker)}
      let(:job_seeker2) {FactoryGirl.create(:job_seeker)}

      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
      end

      it 'success - first application' do
        num_applications = job.number_applicants
        job.apply job_seeker
        job.reload
        expect(job.job_seekers).to eq [job_seeker]
        expect(job.number_applicants).to be(num_applications + 1)
      end
      it 'second application, same job seeker' do
        num_applications = job.number_applicants
        job.apply job_seeker
        first_appl = job.last_application_by_job_seeker(job_seeker)
        job.apply job_seeker
        second_appl = job.last_application_by_job_seeker(job_seeker)
        job.reload
        expect(job.job_seekers).to eq [job_seeker]
        expect(job.number_applicants).to be(num_applications + 2)
        expect(job.last_application_by_job_seeker(job_seeker)).
                        to eq second_appl
      end
      it 'two applications, different job seekers' do
        num_applications = job.number_applicants
        job.apply job_seeker
        first_appl = job.last_application_by_job_seeker(job_seeker)
        job.apply job_seeker2
        second_appl = job.last_application_by_job_seeker(job_seeker2)
        job.reload
        expect(job.job_seekers).to eq [job_seeker, job_seeker2]
        expect(job.number_applicants).to be(num_applications + 2)
        expect(job.last_application_by_job_seeker(job_seeker)).
                        to eq first_appl
        expect(job.last_application_by_job_seeker(job_seeker2)).
                        to eq second_appl
      end
    end
  end
  describe 'Create Job method (AR model and CruncherService)' do

    before(:each) do
      stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})
    end

    it 'succeeds with all parameters' do

      stub_request(:post, CruncherService.service_url + '/job/create').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      job = FactoryGirl.build(:job)

      expect(job.save).to be true
      expect(Job.count).to eq 1
    end

    it 'fails with invalid model parameters' do

      stub_request(:post, CruncherService.service_url + '/job/create').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      job = FactoryGirl.build(:job, title: nil)

      expect(job.save).to be false
      expect(job.errors.full_messages).to include("Title can't be blank")
      expect(Job.count).to eq 0
   end

   it 'fails with valid model but cruncher create failure' do

      stub_request(:post, CruncherService.service_url + '/job/create').
         to_raise(RuntimeError)

      job = FactoryGirl.build(:job)


      expect(job.save).to be false
      expect(Job.count).to eq 0

   end
  end
end
