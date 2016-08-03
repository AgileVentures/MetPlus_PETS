require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplication, type: :model do
  describe 'Database schema' do
    it {is_expected.to have_db_column :job_seeker_id}
    it {is_expected.to have_db_column :job_id }
    it {is_expected.to have_db_column :status }
  end
  describe 'Associations' do
    it { is_expected.to belong_to :job_seeker }
    it { is_expected.to belong_to :job }
  end
  describe 'Validations' do
    let(:job_seeker){FactoryGirl.create(:job_seeker)}
    let(:job){FactoryGirl.create(:job, company: FactoryGirl.create(:company))}
    subject{FactoryGirl.build(:job_application, job: job, job_seeker: job_seeker, status: :active)}

    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    describe 'status' do
       it 'Status -1 should generate exception' do
         expect{subject.status = -1}.to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
       end
       it 'Status 0 should be active' do
         subject.status = 0
         expect(subject.status).to eq 'active'
       end
       it 'Status 1 should be accepted' do
         subject.status = 1
         expect(subject.status).to eq 'accepted'
       end
       it 'Status 2 should be not_accepted' do
         subject.status = 2
         expect(subject.status).to eq 'not_accepted'
       end
       it 'Status 3 should generate exception' do
         expect{subject.status = 3}.to raise_error(ArgumentError).with_message('\'3\' is not a valid status')
       end
    end
  end
  describe '#status_name' do
    
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    let(:job_seeker){FactoryGirl.create(:job_seeker)}
    let(:job){FactoryGirl.create(:job, company: FactoryGirl.create(:company))}
    subject{FactoryGirl.build(:job_application, job: job, job_seeker: job_seeker, status: :active)}
    it 'Status 0 should be Active' do
      subject.status = 0
      expect(subject.status_name).to eq 'Active'
    end
    it 'Status 1 should be Accepted' do
      subject.status = 1
      expect(subject.status_name).to eq 'Accepted'
    end
    it 'Status 2 should be NotAccepted' do
      subject.status = 2
      expect(subject.status_name).to eq 'NotAccepted'
    end
  end
end
