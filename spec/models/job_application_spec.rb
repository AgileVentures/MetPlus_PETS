require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobApplication, type: :model do
  before do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

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
    it { is_expected.to validate_uniqueness_of(:job_seeker_id).scoped_to(:job_id) }
    let(:job_seeker){FactoryGirl.create(:job_seeker)}
    let(:job){FactoryGirl.create(:job, company: FactoryGirl.create(:company))}
    subject{FactoryGirl.build(:job_application, job: job, job_seeker: job_seeker, status: :active)}

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

  describe '#active?' do
    let(:active_job) { FactoryGirl.create(:job) }
    let(:inactive_job) { FactoryGirl.create(:job, status: :filled) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:valid_application) { FactoryGirl.create(:job_application,
                              job: active_job, job_seeker: job_seeker) }
    let(:invalid_application1) { FactoryGirl.create(:job_application,
                                 job: inactive_job, job_seeker: job_seeker) }
    let(:invalid_application2) { FactoryGirl.create(:job_application,
                                 job: active_job, job_seeker: job_seeker,
                                 status: 'accepted') }

    context 'with active job and active application status' do
      it 'returns true' do
        expect(valid_application.active?).to be true
      end
    end
    context 'with inactive job and active application status' do
      it 'returns false' do
        expect(invalid_application1.active?).to be false
      end
    end
    context 'with inactive job and inactive application status' do
      it 'returns false' do
        expect(invalid_application2.active?).to be false
      end
    end
  end

  describe '#accept' do
    let(:active_job) { FactoryGirl.create(:job) }
    let(:job_seeker1) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2) { FactoryGirl.create(:job_seeker) }
    let(:application1) { FactoryGirl.create(:job_application,
                         job: active_job, job_seeker: job_seeker1) }
    let(:application2) { FactoryGirl.create(:job_application,
                         job: active_job, job_seeker: job_seeker2) }

    it 'updates the selected application status to be accepted' do
      expect { application1.accept }.to change{application1.status}.from('active').to('accepted')
    end
    it 'updates unselected application status to be not accepted' do
      expect { application1.accept }.to change{application1.job.job_applications.
                                               find(application2.id).status}.
                                               from('active').to('not_accepted')
    end
    it 'updates the selected job status to be filled' do
      expect { application1.accept }.to change{application1.job.status}.from('active').to('filled')
    end
  end

  describe 'tracking status change history' do
    let(:job)  { FactoryGirl.create(:job) }
    let(:js) { FactoryGirl.create(:job_seeker) }
    let!(:ja1) { FactoryGirl.create(:job_application, job: job) }

    before(:each) do
      sleep(1)
      ja1.accept
    end

    it 'adds a status change record for a new application' do
      expect{ FactoryGirl.create(:job_application, job: job, job_seeker: js) }.
            to change(StatusChange, :count).by 1
    end

    it 'tracks status change times for an application' do
      expect(ja1.status_change_time(:active)).
          to eq StatusChange.second.created_at

      expect(ja1.status_change_time(:accepted)).
          to eq StatusChange.third.created_at
    end
  end

  describe '#reject' do
    let(:active_job) { FactoryGirl.create(:job) }
    let(:job_seeker1) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2) { FactoryGirl.create(:job_seeker) }
    let(:application1) { FactoryGirl.create(:job_application,
                                            job: active_job, job_seeker: job_seeker1) }
    let(:application2) { FactoryGirl.create(:job_application,
                                            job: active_job, job_seeker: job_seeker2) }

    it 'updates the selected application status to be rejected' do
      expect { application1.reject }.to change{application1.status}.from('active').to('not_accepted')
    end
  end

end
