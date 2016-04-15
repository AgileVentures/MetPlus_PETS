require 'rails_helper'

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
    subject{FactoryGirl.build(:job_application, job: job, job_seeker: job_seeker, status: :pending)}
    describe 'status' do
       it 'Status -1 should generate exception' do
         expect{subject.status = -1}.to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
       end
       it 'Status 0 should be pending' do
         subject.status = 0
         expect(subject.status).to eq 'pending'
       end
       it 'Status 1 should be pending' do
         subject.status = 1
         expect(subject.status).to eq 'rejected'
       end
       it 'Status 2 should be hired' do
         subject.status = 2
         expect(subject.status).to eq 'hired'
       end
       it 'Status 3 should generate exception' do
         expect{subject.status = 3}.to raise_error(ArgumentError).with_message('\'3\' is not a valid status')
       end
    end
  end
  describe '#status_name' do
    let(:job_seeker){FactoryGirl.create(:job_seeker)}
    let(:job){FactoryGirl.create(:job, company: FactoryGirl.create(:company))}
    subject{FactoryGirl.build(:job_application, job: job, job_seeker: job_seeker, status: :pending)}
    it 'Status 0 should be Pending' do
      subject.status = 0
      expect(subject.status_name).to eq 'Pending'
    end
    it 'Status 1 should be Rejected' do
      subject.status = 1
      expect(subject.status_name).to eq 'Rejected'
    end
    it 'Status 2 should be Hired' do
      subject.status = 2
      expect(subject.status_name).to eq 'Hired'
    end
  end
end
